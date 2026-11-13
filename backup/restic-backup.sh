#!/usr/bin/env bash
set -euo pipefail
: "${RESTIC_REPOSITORY:?Set RESTIC_REPOSITORY}"
: "${RESTIC_PASSWORD_FILE:?Set RESTIC_PASSWORD_FILE}"
command -v restic >/dev/null || { echo 'restic is not installed' >&2; exit 1; }
[[ -f $RESTIC_PASSWORD_FILE ]] || { echo 'password file missing' >&2; exit 1; }
if [[ $RESTIC_REPOSITORY == /* ]]; then
  repo_parent=$(dirname "$RESTIC_REPOSITORY")
  mountpoint -q "$repo_parent" || { echo 'local repository parent must be a mounted external filesystem' >&2; exit 1; }
fi
restic snapshots >/dev/null 2>&1 || restic init
restic backup /home/chamath-adithya /etc \
  --one-file-system \
  --exclude-caches \
  --exclude-file "$(dirname "$0")/restic-excludes.txt" \
  --tag cham-linux
restic forget --keep-daily 7 --keep-weekly 5 --keep-monthly 12 --prune
restic check
