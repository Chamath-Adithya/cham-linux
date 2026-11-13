#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
version=$(tr -d '[:space:]' < "$root/VERSION")
deb_version=${version//-alpha./~alpha}
deb_version=${deb_version//-beta./~beta}
deb_version=${deb_version//-rc./~rc}
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$root/dist" "$stage/usr/bin" "$stage/usr/lib/cham-linux"
cp -a "$root/packages/cham-core/." "$stage/"
install -m 0755 "$root/bin/cham" "$stage/usr/bin/cham"
install -m 0755 "$root/ai/system-report.sh" "$stage/usr/lib/cham-linux/ai-system-report"
sed -i "s/^Version:.*/Version: $deb_version/" "$stage/DEBIAN/control"
package="$root/dist/cham-linux-core_${deb_version}_all.deb"
rm -f "$root"/dist/cham-linux-core_*.deb
dpkg-deb --root-owner-group --build "$stage" "$package"
(cd "$root/dist" && sha256sum "$(basename "$package")" > SHA256SUMS)
dpkg-deb --info "$package" >/dev/null
dpkg-deb --contents "$package" >/dev/null
