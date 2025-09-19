#!/usr/bin/env bash
set -euo pipefail
N=${1:?usage: $0 N [dir]}
DIR=${2:-/home/user/lab6/data}
i=0
for f in "$DIR"/file_*.txt; do
  [[ -f "$f" ]] || continue
  /home/user/lab6/io_task.sh "$f"
  ((i++))
  (( i>=N )) && break
done