#!/usr/bin/env bash
# OVMF's public snakeoil key is for this disposable VM only, never production.
set -Eeuo pipefail
umask 077
root=$(cd "$(dirname "$0")/.." && pwd)
kernel="$root/build/kernel-6.8.0-149/candidate/arch/x86/boot/bzImage"
mode=${1:-signed}
[[ $mode == signed || $mode == unsigned ]] || { echo 'Usage: test-kernel-secureboot-vm.sh [signed|unsigned]' >&2; exit 2; }
work=$(mktemp -d -t cham-secboot.XXXXXXXX)
trap 'python3 -c "import shutil,sys; shutil.rmtree(sys.argv[1])" "$work"' EXIT
mkdir -p "$work/esp/EFI/BOOT" "$work/esp/boot/grub" "$work/root/bin" "$work/root/proc" "$work/root/sys" "$work/root/dev"
cp /usr/bin/busybox "$work/root/bin/busybox"
mkdir -p "$work/root/lib/x86_64-linux-gnu" "$work/root/lib64"
cp /usr/lib/linux-tools-6.8.0-149/bpftool "$work/root/bin/bpftool"
for lib in libelf.so.1 libz.so.1 libcap.so.2 libc.so.6 libzstd.so.1; do
  cp -L "/lib/x86_64-linux-gnu/$lib" "$work/root/lib/x86_64-linux-gnu/$lib"
done
cp -L /lib64/ld-linux-x86-64.so.2 "$work/root/lib64/ld-linux-x86-64.so.2"
cat > "$work/probe.c" <<'EOF'
#define SEC(NAME) __attribute__((section(NAME), used))
SEC("lsm/file_open") int cham_probe(void *ctx) { return 0; }
char LICENSE[] SEC("license") = "GPL";
EOF
clang -target bpf -O2 -g -c "$work/probe.c" -o "$work/root/probe.o"
cat > "$work/root/init" <<'EOF'
#!/bin/busybox sh
/bin/busybox mount -t proc proc /proc
/bin/busybox mount -t sysfs sys /sys
/bin/busybox mount -t efivarfs efivarfs /sys/firmware/efi/efivars
printf 'CHAM_UEFI_SECUREBOOT='
/bin/busybox od -An -tu1 /sys/firmware/efi/efivars/SecureBoot-*
printf 'CHAM_VM_LSMS='
/bin/busybox mount -t securityfs securityfs /sys/kernel/security
/bin/busybox cat /sys/kernel/security/lsm
echo
/bin/busybox mkdir -p /sys/fs/bpf
/bin/busybox mount -t bpf bpf /sys/fs/bpf
if /bin/bpftool prog load /probe.o /sys/fs/bpf/cham_probe type lsm autoattach; then
  echo CHAM_BPF_LSM_ATTACH_OK
  /bin/bpftool link show
else
  echo CHAM_BPF_LSM_LOAD_FAILED
fi
echo CHAM_SECURE_VM_BOOT_OK
/bin/busybox uname -r
/bin/busybox poweroff -f
EOF
chmod 0755 "$work/root/init"
(cd "$work/root" && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -1 > "$work/esp/initrd")
cat > "$work/grub.cfg" <<'EOF'
set timeout=0
serial --unit=0 --speed=115200
terminal_output serial
search --no-floppy --file --set=root /kernel.efi
linux /kernel.efi console=ttyS0 panic=-1 lsm=landlock,lockdown,yama,integrity,apparmor,bpf
initrd /initrd
boot
EOF
printf '%s\n' 'sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md' 'grub,999,Cham test,grub,999,https://example.invalid' > "$work/sbat.csv"
grub-mkstandalone -O x86_64-efi --sbat="$work/sbat.csv" --modules='normal linux search search_fs_file fat part_msdos part_gpt' -o "$work/grub.efi" "boot/grub/grub.cfg=$work/grub.cfg"
openssl pkey -in /usr/share/ovmf/PkKek-1-snakeoil.key -passin pass:snakeoil -out "$work/test.key" 2>/dev/null
sbsign --key "$work/test.key" --cert /usr/share/ovmf/PkKek-1-snakeoil.pem --output "$work/esp/EFI/BOOT/BOOTX64.EFI" /usr/lib/shim/shimx64.efi >/dev/null
sbsign --key "$work/test.key" --cert /usr/share/ovmf/PkKek-1-snakeoil.pem --output "$work/esp/EFI/BOOT/grubx64.efi" "$work/grub.efi" >/dev/null
if [[ $mode == signed ]]; then
  sbsign --key "$work/test.key" --cert /usr/share/ovmf/PkKek-1-snakeoil.pem --output "$work/esp/kernel.efi" "$kernel" >/dev/null
  sbverify --cert /usr/share/ovmf/PkKek-1-snakeoil.pem "$work/esp/kernel.efi" >/dev/null
else
  cp "$kernel" "$work/esp/kernel.efi"
fi
cp /usr/share/OVMF/OVMF_VARS_4M.snakeoil.fd "$work/vars.fd"
limit=180
[[ $mode != unsigned ]] || limit=30
timeout "$limit" qemu-system-x86_64 -machine q35,smm=on -accel tcg -m 1024 -smp 2 \
  -global driver=cfi.pflash01,property=secure,value=on -display none -serial stdio -no-reboot \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.secboot.fd \
  -drive if=pflash,format=raw,file="$work/vars.fd" \
  -drive format=raw,file="fat:rw:$work/esp" > "$work/serial.log" 2>&1 || true
tail -n 30 "$work/serial.log"
if [[ $mode == unsigned ]]; then
  ! rg -q 'CHAM_SECURE_VM_BOOT_OK' "$work/serial.log" || { echo 'FAIL: unsigned kernel booted.' >&2; exit 1; }
  rg -qi 'bad shim signature|invalid signature|verification failed|prohibited by secure boot' "$work/serial.log" || { echo 'FAIL: signature rejection not confirmed.' >&2; exit 1; }
  echo 'PASS: unsigned kernel rejected by the Secure Boot test chain.'
  exit 0
fi
rg -q 'CHAM_SECURE_VM_BOOT_OK' "$work/serial.log" || { echo 'FAIL: VM boot marker absent.' >&2; exit 1; }
rg -q 'CHAM_UEFI_SECUREBOOT= *[0-9]+ +[0-9]+ +[0-9]+ +[0-9]+ +1' "$work/serial.log" || { echo 'FAIL: Secure Boot not confirmed enabled in guest.' >&2; exit 1; }
rg -q '6.8.12-cham-lab1' "$work/serial.log" || { echo 'FAIL: wrong kernel.' >&2; exit 1; }
rg -q 'CHAM_BPF_LSM_ATTACH_OK' "$work/serial.log" || { echo 'FAIL: BPF LSM program did not attach.' >&2; exit 1; }
echo 'PASS: signed candidate booted an isolated Secure Boot VM using a public test key.'
echo 'This does not establish laptop Secure Boot or release-key readiness; run unsigned mode for a negative control.'
