#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
site=${1:?output directory required}
codename=stable
component=main
arch=all

rm -rf "$site"
mkdir -p "$site/pool/main/c/cham-linux-core" "$site/dists/$codename/$component/binary-$arch"
cp "$root"/dist/cham-linux-core_*.deb "$site/pool/main/c/cham-linux-core/"

packages="$site/dists/$codename/$component/binary-$arch/Packages"
cd "$site"
dpkg-scanpackages --arch "$arch" pool /dev/null >"${packages#$site/}"
gzip -9 -c "${packages#$site/}" >"${packages#$site/}.gz"

release_dir="$site/dists/$codename"
cd "$release_dir"
apt-ftparchive \
  -o APT::FTPArchive::Release::Origin='Cham Linux' \
  -o APT::FTPArchive::Release::Label='Cham Linux' \
  -o APT::FTPArchive::Release::Suite="$codename" \
  -o APT::FTPArchive::Release::Codename="$codename" \
  -o APT::FTPArchive::Release::Architectures="$arch" \
  -o APT::FTPArchive::Release::Components="$component" \
  release . >Release
gpg --batch --yes --local-user "$CHAM_APT_SIGNING_FINGERPRINT" --clearsign -o InRelease Release
gpg --batch --yes --local-user "$CHAM_APT_SIGNING_FINGERPRINT" -abs -o Release.gpg Release

cp "$root/keys/cham-linux-archive.asc" "$site/cham-linux-archive.asc"
cat >"$site/index.html" <<'EOF'
<!doctype html><meta charset="utf-8"><title>Cham Linux APT Repository</title>
<h1>Cham Linux APT Repository</h1><p>Signed package updates for Cham Linux.</p>
EOF
