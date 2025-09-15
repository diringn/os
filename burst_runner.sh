#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab5

N="${1:-}"; K="${2:-}"
[[ "$N" =~ ^[0-9]+$ && "$K" =~ ^[0-9]+$ ]] || { echo "usage: $0 <N> <K>"; exit 1; }

pids=()
for ((i=1;i<=K;i++)); do
  ./newmem.bash "$N" & pids+=( "$!" )
  echo "Started #$i PID=${pids[-1]}"
  sleep 1
done

ok=0; fail=0
for pid in "${pids[@]}"; do
  if wait "$pid"; then
    ((ok++))
  else
    ((fail++))
  fi
done

echo "Done: OK=$ok, FAIL=$fail"
echo "Recent kernel messages about newmem:"
dmesg | grep -F "newmem.bash" | tail -n 10 || true