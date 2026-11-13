#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo 'Run with sudo.' >&2; exit 1; }
exec 9>/run/lock/cham-linux-repair-sources.lock
flock -n 9 || { echo 'Another source repair is active.' >&2; exit 1; }
if pgrep -x 'apt|apt-get|dpkg' >/dev/null; then echo 'APT or dpkg is running.' >&2; exit 1; fi
source_file=/etc/apt/sources.list.d/ubuntu.sources
[[ -f $source_file ]] || { echo 'Ubuntu deb822 source file not found.' >&2; exit 1; }
grep -Eq '^Suites:.*\bnoble\b' "$source_file" || { echo 'Unexpected Ubuntu suite; refusing automatic edit.' >&2; exit 1; }
stamp=$(date +%Y%m%d-%H%M%S)
backup=/var/backups/cham-linux/sources-$stamp
install -d -m 0700 "$backup"
cp -a /etc/apt/sources.list /etc/apt/sources.list.d "$backup/" 2>/dev/null || true
sed -i -E 's/[[:space:]]+noble-proposed\b//g' "$source_file"
if [[ -f /etc/apt/sources.list.d/spotify.list && -f /etc/apt/sources.list.d/spotify.sources ]]; then
  mv /etc/apt/sources.list.d/spotify.list "$backup/spotify.list.disabled"
fi

# Spotify rotated its repository key. Verify the complete official fingerprint
# before replacing the old embedded key with a scoped keyring file.
spotify_key=$(mktemp)
trap 'rm -f "$spotify_key"' EXIT
curl -fsSL https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc -o "$spotify_key"
fingerprint=$(gpg --batch --show-keys --with-colons "$spotify_key" | awk -F: '$1 == "fpr" {print $10; exit}')
expected=E1096BCBFF6D418796DE78515384CE82BA52C83A
[[ $fingerprint == "$expected" ]] || { echo "Spotify key fingerprint mismatch: $fingerprint" >&2; exit 1; }
install -d -m 0755 /etc/apt/keyrings
install -m 0644 "$spotify_key" /etc/apt/keyrings/spotify.asc
printf '%s\n' \
  'Types: deb' \
  'URIs: https://repository.spotify.com' \
  'Suites: stable' \
  'Components: non-free' \
  'Architectures: amd64' \
  'Signed-By: /etc/apt/keyrings/spotify.asc' \
  > /etc/apt/sources.list.d/spotify.sources

# These vendors publish amd64 packages only; avoid irrelevant i386 requests.
mongo=/etc/apt/sources.list.d/mongodb-org-6.0.list
if [[ -f $mongo ]] && ! grep -q 'arch=' "$mongo"; then
  sed -i 's/^deb \[ /deb [ arch=amd64 /' "$mongo"
fi
antigravity=/etc/apt/sources.list.d/antigravity.list
if [[ -f $antigravity ]] && ! grep -q 'arch=' "$antigravity"; then
  sed -i 's/^deb \[/deb [arch=amd64 /' "$antigravity"
fi
apt-get update --error-on=any
apt-get check
echo "Source repair complete. Backup: $backup"
