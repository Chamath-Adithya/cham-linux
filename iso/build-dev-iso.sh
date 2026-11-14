#!/usr/bin/env bash
# Local-only development media. This script never writes to a disk device.
set -Eeuo pipefail
umask 077
[[ $# == 2 ]] || { echo 'Usage: build-dev-iso.sh BASE.iso NEW-OUTPUT.iso' >&2; exit 2; }
root=$(cd "$(dirname "$0")/.." && pwd)
base=$(realpath "$1")
out=$(realpath -m "$2")
[[ -f $base && ! -e $out && $base != "$out" ]] || { echo 'Input must exist and output must be a new file.' >&2; exit 1; }
[[ $(basename "$base") == ubuntu-24.04.5.1-desktop-amd64.iso ]] || { echo 'Unexpected base ISO name.' >&2; exit 1; }
for cmd in xorriso gpgv curl sha256sum dpkg-deb dpkg git; do
  command -v "$cmd" >/dev/null || { echo "Missing required command: $cmd" >&2; exit 1; }
done
[[ -z $(git -C "$root" status --porcelain) ]] || { echo 'Commit or move all work before building: this uses the committed source tree.' >&2; exit 1; }
tmp=$(mktemp -d -t cham-iso-build.XXXXXXXX)
trap 'python3 -c "import shutil,sys; shutil.rmtree(sys.argv[1])" "$tmp"' EXIT
curl -fsSL --max-time 60 https://releases.ubuntu.com/noble/SHA256SUMS -o "$tmp/SHA256SUMS"
curl -fsSL --max-time 60 https://releases.ubuntu.com/noble/SHA256SUMS.gpg -o "$tmp/SHA256SUMS.gpg"
gpgv --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg "$tmp/SHA256SUMS.gpg" "$tmp/SHA256SUMS"
expected=4da4a0c9035da8e68a59a838674f403f0a54472c78a83b4fb7f78d03588f85a7
rg -Fq "$expected *ubuntu-24.04.5.1-desktop-amd64.iso" "$tmp/SHA256SUMS" || { echo 'Pinned image is absent from signed checksum list.' >&2; exit 1; }
[[ $(sha256sum "$base" | cut -d ' ' -f 1) == "$expected" ]] || { echo 'Base ISO hash mismatch.' >&2; exit 1; }
mkdir -p "$tmp/source" "$tmp/media/cham"
git -C "$root" archive HEAD | (umask 022; tar -xf - -C "$tmp/source")
(umask 022; make -C "$tmp/source" package)
mapfile -t packages < <(find "$tmp/source/dist" -maxdepth 1 -name 'cham-linux-core_*.deb' -type f)
[[ ${#packages[@]} == 1 ]] || { echo 'Expected exactly one package.' >&2; exit 1; }
mkdir -p "$tmp/pkg"
dpkg-deb -R "${packages[0]}" "$tmp/pkg"
version=$(dpkg-deb -f "${packages[0]}" Version)
dpkg --validate-version "${version}+iso1"
sed -i "s/^Version:.*/Version: ${version}+iso1/" "$tmp/pkg/DEBIAN/control"
install -d -m 0755 "$tmp/pkg/usr/share/doc/cham-linux-core"
install -m 0644 "$tmp/source/LICENSE" "$tmp/pkg/usr/share/doc/cham-linux-core/LICENSE"
install -m 0644 "$tmp/source/LICENSING.md" "$tmp/pkg/usr/share/doc/cham-linux-core/LICENSING.md"
dpkg-deb --root-owner-group --build "$tmp/pkg" "$tmp/media/cham/cham-linux-core.deb"
install -m 0644 "$tmp/source/keys/cham-linux-archive.asc" "$tmp/media/cham/cham-linux-archive.asc"
install -m 0644 "$tmp/source/iso/setup-target.sh" "$tmp/media/cham/setup-target.sh"
install -m 0644 "$tmp/source/iso/README.md" "$tmp/media/cham/README.md"
install -m 0644 "$tmp/source/iso/autoinstall.yaml" "$tmp/media/autoinstall.yaml"
git -C "$root" rev-parse HEAD > "$tmp/media/cham/SOURCE-COMMIT"
(cd "$tmp/media/cham" && sha256sum cham-linux-core.deb cham-linux-archive.asc setup-target.sh README.md SOURCE-COMMIT > SHA256SUMS)
# Preserve the source's boot records and volume UUID used by boot components.
xorriso -indev "$base" -outdev "$out" -boot_image any replay \
  -volume_date uuid 2026091423192100 \
  -map "$tmp/media/cham" /cham -map "$tmp/media/autoinstall.yaml" /autoinstall.yaml -commit
sha256sum "$out" > "$out.sha256"
echo "Local developer ISO written: $out"
echo 'Do not redistribute or install on real hardware before full review and testing.'
