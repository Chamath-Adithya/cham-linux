#!/usr/bin/env bash
set -euo pipefail
: "${RESTIC_REPOSITORY:?Set RESTIC_REPOSITORY}"
: "${RESTIC_PASSWORD_FILE:?Set RESTIC_PASSWORD_FILE}"
target=${1:?Usage: restic-restore-test.sh /path/on-separate-test-filesystem}
[[ ! -e $target ]] || { echo 'restore target already exists' >&2; exit 1; }
mkdir -p "$target"
restic restore latest --target "$target"
test -d "$target/home/chamath-adithya"
test -d "$target/etc"
find "$target/home/chamath-adithya" -type f -print -quit | grep -q .
echo "Restore completed and basic structure verified: $target"
echo 'Open representative files and test database restore before recording a successful drill.'
