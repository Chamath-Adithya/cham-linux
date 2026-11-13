#!/usr/bin/env bash
set -euo pipefail
result=${1:?Usage: loq-cycle-record.sh PASS-or-FAIL optional-note}
note=${2:-}
case "$result" in PASS|FAIL) ;; *) echo 'Result must be PASS or FAIL.' >&2; exit 2 ;; esac
mkdir -p reports/private
file="reports/private/loq-cycles-$(date +%Y%m%d).tsv"
if [[ ! -f $file ]]; then printf 'time\tresult\tkernel\tnvidia\tsleep\tnote\n' > "$file"; fi
driver=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo unavailable)
printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$(date --iso-8601=seconds)" "$result" "$(uname -r)" "$driver" "$(cat /sys/power/mem_sleep)" "${note//$'\t'/ }" >> "$file"
echo "$file"
