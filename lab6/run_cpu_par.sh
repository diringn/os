#!/usr/bin/env bash
set -euo pipefail
N=${1:?usage: $0 N W}
W=${2:?}
pids=()
for ((k=0;k<N;k++)); do
  /home/user/lab6/cpu_heavy.sh "$k" "$W" >/dev/null &
  pids+=("$!")
done
ok=0
for p in "${pids[@]}"; do wait "$p" && ((ok++)) || true; done
exit 0