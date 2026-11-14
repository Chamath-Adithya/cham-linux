#!/usr/bin/env bash
# Experimental build only: no install, signing enrollment, GRUB or host writes.
set -Eeuo pipefail
umask 077
root=$(cd "$(dirname "$0")/.." && pwd)
base="$root/build/kernel-6.8.0-149"
src="$base/linux-source-6.8.0"
out="$base/candidate"
certdir="$base/ubuntu-buildinfo/usr/lib/linux/6.8.0-149-generic"
[[ $(dpkg-query -W -f='${Version}' linux-source-6.8.0) == 6.8.0-149.149 ]] || { echo 'Unexpected Ubuntu source version.' >&2; exit 1; }
for file in "$src/Makefile" "$base/out/.config" "$certdir/canonical-certs.pem" "$certdir/canonical-revoked-certs.pem" "$certdir/config"; do
  [[ -s $file ]] || { echo "Missing required input: $file" >&2; exit 1; }
done
cmp -s /boot/config-6.8.0-149-generic "$certdir/config" || { echo 'Ubuntu buildinfo config does not match host baseline.' >&2; exit 1; }
available=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
swapfree=$(awk '/SwapFree:/ {print $2}' /proc/meminfo)
(( available >= 3145728 && swapfree >= 4194304 )) || { echo 'Insufficient RAM/swap headroom.' >&2; exit 1; }
(( $(df -Pk "$base" | awk 'NR==2 {print $4}') >= 31457280 )) || { echo 'At least 30 GiB free disk required.' >&2; exit 1; }
if [[ ! -d $out ]]; then cp -a --reflink=auto "$base/out" "$out"; fi
chmod 700 "$out"
mkdir -p "$out/debian"
install -m 0644 "$certdir/canonical-certs.pem" "$out/debian/canonical-certs.pem"
install -m 0644 "$certdir/canonical-revoked-certs.pem" "$out/debian/canonical-revoked-certs.pem"
"$src/scripts/config" --file "$out/.config" --set-str LOCALVERSION '-cham-lab1' \
  --disable LOCALVERSION_AUTO --set-str SYSTEM_TRUSTED_KEYS 'debian/canonical-certs.pem' \
  --set-str SYSTEM_REVOCATION_KEYS 'debian/canonical-revoked-certs.pem'
make -C "$src" O="$out" olddefconfig
# Guard the long compile. Terminate only this make process group if resources
# become unsafe; partial output stays in the private candidate directory.
setsid make -C "$src" O="$out" -j1 bzImage modules &
build_pid=$!
while kill -0 "$build_pid" 2>/dev/null; do
  sleep 5
  available=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
  swapfree=$(awk '/SwapFree:/ {print $2}' /proc/meminfo)
  temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
  if (( available < 1572864 || swapfree < 3145728 || temp > 92000 )); then
    echo "Stopping build: memory=${available} KiB swap=${swapfree} KiB temperature=${temp} mC" >&2
    kill -TERM -- "-$build_pid" 2>/dev/null || true
    wait "$build_pid" || true
    exit 1
  fi
done
wait "$build_pid"
[[ -s $out/Module.symvers && -s $out/arch/x86/boot/bzImage ]] || { echo 'Missing full-build outputs.' >&2; exit 1; }
echo "Candidate build complete: $out"
echo 'Experimental only; not installed, not Secure Boot signed, not release validated.'
