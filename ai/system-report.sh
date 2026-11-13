#!/usr/bin/env bash
set -euo pipefail

redact() {
  sed "s|$HOME|~|g"
}

section() {
  printf '\n## %s\n' "$1"
}

section 'Cham Linux local AI diagnostic evidence'
printf 'Generated: '; date --iso-8601=seconds
if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  printf 'OS: %s\n' "${PRETTY_NAME:-unknown}"
fi
printf 'Kernel: '; uname -r
printf 'Uptime: '; uptime -p

section 'Resource summary'
free -h 2>/dev/null || true
df -h / 2>/dev/null || true

section 'GPU'
if command -v nvidia-smi >/dev/null; then
  nvidia-smi --query-gpu=name,driver_version,memory.total,memory.used,temperature.gpu --format=csv,noheader 2>&1 || true
fi

section 'Failed services'
systemctl --failed --no-pager --plain 2>&1 || true
systemctl --user --failed --no-pager --plain 2>&1 || true

section 'Current boot warnings and errors (maximum 60 lines)'
journalctl -b --no-pager -p warning -n 60 -o short-iso 2>&1 | redact || true

section 'Power and local AI service'
printf 'Sleep modes: '; cat /sys/power/mem_sleep 2>/dev/null || true
if command -v ollama >/dev/null; then
  printf 'Ollama: '; ollama --version 2>&1 || true
  printf 'Ollama models:\n'; ollama list 2>&1 || true
fi

section 'Listening addresses'
ss -lntH 2>/dev/null | awk '{print $4}' | sort -u

printf '\nEvidence is local and read-only. Review it before sharing outside this machine.\n'
