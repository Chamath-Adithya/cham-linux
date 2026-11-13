#!/usr/bin/env bash
set -Eeuo pipefail

repo_root=$(cd "$(dirname "$0")" && pwd)
key_source="$repo_root/keys/cham-linux-archive.asc"
keyring=/etc/apt/keyrings/cham-linux-archive.asc
source_file=/etc/apt/sources.list.d/cham-linux.sources

if [[ ${EUID} -ne 0 ]]; then
  echo "Run with sudo: sudo ./install-apt-repository.sh" >&2
  exit 1
fi

install -d -m 0755 /etc/apt/keyrings
install -m 0644 "$key_source" "$keyring"
cat >"$source_file" <<EOF
Types: deb
URIs: https://chamath-adithya.github.io/cham-linux
Suites: stable
Components: main
Architectures: amd64 all
Signed-By: $keyring
EOF

apt-get update --error-on=any
apt-get install -y cham-linux-core
echo "Cham Linux APT updates enabled. Future updates: sudo apt update && sudo apt upgrade"
