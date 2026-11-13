#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get install --only-upgrade -y spotify-client

# Preserve old crash reports before clearing the upload queue that repeatedly
# times out apport-autoreport. New crashes will continue to be collected.
stamp=$(date +%Y%m%d-%H%M%S)
crash_backup="/var/backups/cham-linux/crash-reports-${stamp}"
install -d -m 0700 "${crash_backup}"
find /var/crash -maxdepth 1 -type f -exec mv -t "${crash_backup}" -- {} +

systemctl reset-failed apport-autoreport.service
apt-get check

echo "Host finalization complete. Crash backup: ${crash_backup}"
