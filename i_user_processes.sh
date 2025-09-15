#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab2

TARGET_USER="${1:-user}"

LIST="$(ps -u "$TARGET_USER" -o pid= -o cmd= 2>/dev/null || true)"

COUNT="$(printf '%s\n' "$LIST" | sed '/^[[:space:]]*$/d' | wc -l)"

{
  echo "$COUNT"
  printf '%s\n' "$LIST" | awk '{pid=$1; $1=""; sub(/^ +/,""); print pid ":" $0}'
} > user_processes.txt

echo "Done: $(pwd)/user_processes.txt"