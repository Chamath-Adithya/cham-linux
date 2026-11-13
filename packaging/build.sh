#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$root/dist" "$stage/usr/bin"
cp -a "$root/packages/cham-core/." "$stage/"
install -m 0755 "$root/bin/cham" "$stage/usr/bin/cham"
dpkg-deb --root-owner-group --build "$stage" "$root/dist/cham-linux-core_0.1.0~alpha1_all.deb"
(cd "$root/dist" && sha256sum cham-linux-core_*.deb > SHA256SUMS)
dpkg-deb --info "$root/dist/cham-linux-core_0.1.0~alpha1_all.deb" >/dev/null
dpkg-deb --contents "$root/dist/cham-linux-core_0.1.0~alpha1_all.deb" >/dev/null
