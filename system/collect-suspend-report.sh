#!/usr/bin/env bash
set -euo pipefail
boot=${1:--1}
out=${2:-"suspend-report-$(date +%Y%m%d-%H%M%S).txt"}
{
  date --iso-8601=seconds
  uname -a
  cat /proc/cmdline
  printf 'sleep modes: '; cat /sys/power/mem_sleep
  nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>&1 || true
  systemctl is-enabled nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service 2>&1 || true
  journalctl -b "$boot" -u systemd-suspend.service -u nvidia-suspend.service -u nvidia-resume.service --no-pager
  journalctl -b "$boot" -k --no-pager | rg -i 'PM:|NVRM|Xid|nvidia|drm|ACPI.*error|suspend|resume' | tail -n 800
} > "$out"
echo "$out"
