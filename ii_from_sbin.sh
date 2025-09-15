#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab2

tmpfile="$(mktemp)"
for d in /proc/[0-9]*; do
  pid="${d##*/}"
  if exe_path="$(readlink -f "$d/exe" 2>/dev/null)"; then
    case "$exe_path" in
      /sbin/*) echo "$pid" >> "$tmpfile" ;;
    esac
  fi
done

sort -n "$tmpfile" | uniq > pids_from_sbin.txt
rm -f "$tmpfile"
echo "Done: $(pwd)/pids_from_sbin.txt"