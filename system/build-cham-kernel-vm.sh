#!/usr/bin/env bash
# Builds a disposable VM-only image; never installs or changes host kernels.
set -Eeuo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/build/kernel-6.8.0-149/linux-source-6.8.0"
out="$root/build/kernel-6.8.0-149/out"
[[ -f "$src/Makefile" && -f "$out/.config" ]] || { echo 'Prepare Ubuntu source and config first.' >&2; exit 1; }
patch_file="$root/kernel/patches/0001-bpf-remove-obsolete-getsecid-btf-ids.patch"
if patch --dry-run --silent -R -p1 -d "$src" < "$patch_file" >/dev/null 2>&1; then
  echo 'Upstream BPF patch already present.'
elif patch --dry-run --silent -p1 -d "$src" < "$patch_file" >/dev/null 2>&1; then
  patch --batch -p1 -d "$src" < "$patch_file"
else
  echo 'BPF patch does not match source; stop and review provenance.' >&2
  exit 1
fi
available=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
(( available >= 3145728 )) || { echo 'Need at least 3 GiB available RAM.' >&2; exit 1; }
[[ $(df -Pk "$root" | awk 'NR==2 {print $4}') -ge 20971520 ]] || { echo 'Need at least 20 GiB free disk.' >&2; exit 1; }
# Ubuntu source tarball omits Canonical's build certificate files. This test
# image deliberately has a different trust configuration and is VM-only.
"$src/scripts/config" --file "$out/.config" --set-str LOCALVERSION '-cham-vmtest' \
  --disable LOCALVERSION_AUTO --set-str SYSTEM_TRUSTED_KEYS '' \
  --set-str SYSTEM_REVOCATION_KEYS ''
make -C "$src" O="$out" olddefconfig
make -C "$src" O="$out" -j1 bzImage
printf '\nVM-only image: %s\n' "$out/arch/x86/boot/bzImage"
echo 'Not signed or validated for the host; do not install this image.'
