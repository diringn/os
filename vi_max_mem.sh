#!/usr/bin/env bash
set -euo pipefail

pagesize="$(getconf PAGESIZE 2>/dev/null || echo 4096)"

max_bytes=0
max_pid=""
max_cmd=""

for d in /proc/[0-9]*; do
  pid="${d##*/}"
  resident_pages="$(awk '{print $2}' "$d/statm" 2>/dev/null || true)"
  [[ -n "${resident_pages:-}" ]] || continue
  bytes=$(( resident_pages * pagesize ))

  cmd="$(tr '\0' ' ' < "$d/cmdline" 2>/dev/null || true)"
  [[ -n "$cmd" ]] || cmd="$(cat "$d/comm" 2>/dev/null || echo "?")"

  if (( bytes > max_bytes )); then
    max_bytes=$bytes
    max_pid=$pid
    max_cmd="$cmd"
  fi
done

echo "PROC(/proc/*/statm): PID=$max_pid CMD=$max_cmd BYTES=$max_bytes"

ps -eo pid=,rss=,comm= --sort=-rss 2>/dev/null | awk 'NR==1{printf "PS(RSS,KB):   PID=%s CMD=%s RSS_KB=%s\n", $1, $3, $2}'
command -v top >/dev/null 2>&1 || exit 0