#!/bin/sh
# Runs in Ubuntu's installer environment after the user's interactive install.
set -eu
media=/cdrom/cham
target=/target
test "$(id -u)" -eq 0
test -f "$target/etc/os-release"
test -f "$media/SHA256SUMS"
cd "$media"
sha256sum -c SHA256SUMS
install -d -m 0755 "$target/tmp/cham-installer" "$target/etc/apt/keyrings" "$target/etc/apt/sources.list.d"
install -m 0644 ./cham-linux-core.deb "$target/tmp/cham-installer/cham-linux-core.deb"
install -m 0644 ./cham-linux-archive.asc "$target/etc/apt/keyrings/cham-linux-archive.asc"
cat > "$target/etc/apt/sources.list.d/cham-linux.sources" <<'EOF'
Types: deb
URIs: https://chamath-adithya.github.io/cham-linux
Suites: stable
Components: main
Architectures: all
Signed-By: /etc/apt/keyrings/cham-linux-archive.asc
EOF
# Internet access is required to resolve dependencies from Ubuntu's archives.
curtin in-target --target="$target" -- apt-get update --error-on=any
curtin in-target --target="$target" -- apt-get install -y /tmp/cham-installer/cham-linux-core.deb
curtin in-target --target="$target" -- dpkg-query -W cham-linux-core
echo 'Cham package installed. The user can apply Cham Experience after login.'
