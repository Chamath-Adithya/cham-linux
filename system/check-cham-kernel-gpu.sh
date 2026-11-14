#!/usr/bin/env bash
set -Eeuo pipefail

expected=${1:-6.8.12-cham-lab1}
running=$(uname -r)
if [[ $running != "$expected" ]]; then
  printf 'FAIL: running kernel %s; expected %s\n' "$running" "$expected" >&2
  exit 1
fi
command -v nvidia-smi >/dev/null || { echo 'FAIL: nvidia-smi unavailable' >&2; exit 1; }
for module in nvidia nvidia_modeset nvidia_drm; do
  [[ -d /sys/module/$module ]] || { echo "FAIL: $module not loaded" >&2; exit 1; }
done
nvidia-smi --query-gpu=name,driver_version,utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv
printf 'PASS: NVIDIA modules are loaded and nvidia-smi responds on %s.\n' "$running"
echo 'This does not test GPU rendering, compute, suspend, or stability.'
