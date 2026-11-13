#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
mapfile -t scripts < <(find "$root" -type f -name '*.sh' -o -path "$root/bin/cham")
for script in "${scripts[@]}"; do bash -n "$script"; done
if command -v shellcheck >/dev/null; then shellcheck "${scripts[@]}"; fi
python3 -m json.tool "$root/manifests/channels.json" >/dev/null
python3 -m json.tool "$root/manifests/loq-15arp9.json" >/dev/null
if rg -n '(BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|gh[opsu]_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16})' "$root" -g '!tests/static.sh'; then
  echo 'possible committed secret' >&2
  exit 1
fi
if rg -n 'kali.org|kali-rolling|archlinux.org' "$root/packages"; then
  echo 'foreign host repository found in package payload' >&2
  exit 1
fi
echo 'Static checks passed.'
