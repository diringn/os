#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab2

if [[ $EUID -ne 0 ]]; then exec sudo bash "$0" "$@"; fi

t0="$(mktemp)"; t1="$(mktemp)"

for d in /proc/[0-9]*; do
  pid="${d##*/}"
  rb="$(awk '/^read_bytes:/{print $2}' "$d/io" 2>/dev/null || true)"
  [[ -n "${rb:-}" ]] || continue
  cmd="$(tr '\0' ' ' < "$d/cmdline" 2>/dev/null || cat "$d/comm" 2>/dev/null || echo "?")"
  printf "%s\t%s\t%s\n" "$pid" "$rb" "$cmd" >> "$t0"
done

sleep "${1:-60}"

for d in /proc/[0-9]*; do
  pid="${d##*/}"
  rb="$(awk '/^read_bytes:/{print $2}' "$d/io" 2>/dev/null || true)"
  [[ -n "${rb:-}" ]] || continue
  cmd="$(tr '\0' ' ' < "$d/cmdline" 2>/dev/null || cat "$d/comm" 2>/dev/null || echo "?")"
  printf "%s\t%s\t%s\n" "$pid" "$rb" "$cmd" >> "$t1"
done

join -t $'\t' -j 1 <(sort -k1,1 "$t0") <(sort -k1,1 "$t1") 2>/dev/null \
| awk -F'\t' '
  { pid=$1; rb0=$2+0; cmd0=$3; rb1=$4+0; cmd1=$5;
    delta=rb1-rb0; if (delta<0) next;
    cmd=(cmd1!=""?cmd1:cmd0);
    printf "%s\t%s\t%u\n", pid, cmd, delta
  }' \
| sort -k3,3nr \
| head -n 3 \
| awk -F'\t' '{printf "%s:%s:%s\n", $1, $2, $3}'

rm -f "$t0" "$t1"