#!/usr/bin/env bash
# Build a local-only experiment. No host installation or boot change occurs.
set -Eeuo pipefail
umask 077
root=$(cd "$(dirname "$0")/.." && pwd)
base="$root/build/kernel-6.8.0-149"
release=6.8.12-cham-lab1
image="$base/candidate/arch/x86/boot/bzImage"
modules="$base/stage/lib/modules/$release"
expected=ea4d99c127da722c323bebafd5c9981b946ed418041076e91c66715ab4f7671f
[[ -f $image && -d $modules && -f $base/candidate/System.map ]] || { echo 'Missing candidate build or staged modules.' >&2; exit 1; }
[[ $(sha256sum "$image" | cut -d ' ' -f 1) == "$expected" ]] || { echo 'Unexpected candidate image hash.' >&2; exit 1; }
for module in nvidia nvidia-drm nvidia-modeset nvidia-uvm nvidia-peermem; do
  file="$modules/updates/cham-test/$module.ko"
  [[ -f $file && $(modinfo -F vermagic "$file") == "$release "* ]] || { echo "Invalid $module module." >&2; exit 1; }
done
work=$(mktemp -d "$base/lab-package.XXXXXXXX")
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/DEBIAN" "$work/boot" "$work/lib/modules"
chmod 0755 "$work" "$work/DEBIAN" "$work/boot" "$work/lib" "$work/lib/modules"
cp -a --reflink=auto "$modules" "$work/lib/modules/$release"
rm -f "$work/lib/modules/$release/build" "$work/lib/modules/$release/source"
find "$work/lib/modules/$release" -type d -exec chmod 0755 {} +
find "$work/lib/modules/$release" -type f -exec chmod 0644 {} +
install -m 0644 "$image" "$work/boot/vmlinuz-$release"
install -m 0644 "$base/candidate/System.map" "$work/boot/System.map-$release"
install -m 0644 "$base/candidate/.config" "$work/boot/config-$release"
cat > "$work/DEBIAN/control" <<'EOF'
Package: cham-linux-kernel-lab
Version: 0.0.1~lab2
Architecture: amd64
Maintainer: Cham Linux <local@localhost>
Section: kernel
Priority: optional
Depends: initramfs-tools, kmod, grub-common
Description: Experimental Cham kernel for local hardware testing only
 Unsigned experimental kernel and NVIDIA modules. Not a stable release.
EOF
cat > "$work/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
if [ "$1" = configure ]; then
  depmod 6.8.12-cham-lab1
  if [ -e /boot/initrd.img-6.8.12-cham-lab1 ]; then
    update-initramfs -u -k 6.8.12-cham-lab1
  else
    update-initramfs -c -k 6.8.12-cham-lab1
  fi
  update-grub
fi
EOF
cat > "$work/DEBIAN/postrm" <<'EOF'
#!/bin/sh
set -e
if [ "$1" = remove ] || [ "$1" = purge ]; then
  if [ -e /boot/initrd.img-6.8.12-cham-lab1 ]; then
    update-initramfs -d -k 6.8.12-cham-lab1
  fi
  update-grub
fi
EOF
chmod 0755 "$work/DEBIAN/postinst" "$work/DEBIAN/postrm"
mkdir -p "$base/artifacts"
dpkg-deb --root-owner-group -Zgzip -z1 --build "$work" "$base/artifacts/cham-linux-kernel-lab_0.0.1~lab2_amd64.deb"
echo 'Lab artifact built; do not publish as a stable or signed kernel.'
