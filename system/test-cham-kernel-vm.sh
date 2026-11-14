#!/usr/bin/env bash
set -Eeuo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
case ${1:-baseline} in
  baseline) image="$root/build/kernel-6.8.0-149/out/arch/x86/boot/bzImage"; expected=6.8.12-cham-vmtest ;;
  candidate) image="$root/build/kernel-6.8.0-149/candidate/arch/x86/boot/bzImage"; expected=6.8.12-cham-lab1 ;;
  *) echo 'Usage: test-cham-kernel-vm.sh [baseline|candidate]' >&2; exit 2 ;;
esac
[[ -r $image ]] || { echo 'VM-only kernel image not built yet.' >&2; exit 1; }
[[ -r /usr/bin/busybox ]] || { echo 'Static busybox is required.' >&2; exit 1; }
scratch=$(mktemp -d -t cham-kernel-vm.XXXXXXXX)
trap 'rm -rf -- "$scratch"' EXIT
mkdir -p "$scratch/root/bin" "$scratch/root/proc" "$scratch/root/sys" "$scratch/root/dev"
cp /usr/bin/busybox "$scratch/root/bin/busybox"
printf '%s\n' '#!/bin/busybox sh' 'echo CHAM_VM_BOOT_OK' '/bin/busybox uname -r' '/bin/busybox poweroff -f' > "$scratch/root/init"
chmod 0755 "$scratch/root/init"
(cd "$scratch/root" && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -1 > "$scratch/initramfs.cpio.gz")
qemu-system-x86_64 -accel tcg -m 768 -smp 2 -nographic -no-reboot \
  -kernel "$image" -initrd "$scratch/initramfs.cpio.gz" \
  -append 'console=ttyS0 panic=-1' > "$scratch/serial.log" 2>&1 &
qemu_pid=$!
for _ in $(seq 1 120); do
  if rg -q 'CHAM_VM_BOOT_OK' "$scratch/serial.log" && rg -Fq "$expected" "$scratch/serial.log"; then
    tail -n 12 "$scratch/serial.log"
    wait "$qemu_pid" || true
    echo 'PASS: experimental kernel booted the isolated initramfs.'
    exit 0
  fi
  if ! kill -0 "$qemu_pid" 2>/dev/null; then break; fi
  sleep 1
done
kill "$qemu_pid" 2>/dev/null || true
wait "$qemu_pid" 2>/dev/null || true
tail -n 60 "$scratch/serial.log"
echo 'FAIL: VM boot marker not observed.' >&2
exit 1
