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
apt-get update --error-on=any
apt-get check
echo "Source repair complete. Backup: $backup"
