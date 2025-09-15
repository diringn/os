#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab2

raw="art_raw.tsv"
> "$raw"

for d in /proc/[0-9]*; do
  pid="${d##*/}"

  ppid="$(awk '/^PPid:/{print $2}' "$d/status" 2>/dev/null || true)"
  [[ -n "${ppid:-}" ]] || continue

  read -r ser ns < <(
    awk '
      /(^| )se\.sum_exec_runtime[[:space:]]*:/{ser=$NF}
      /(^| )sum_exec_runtime[[:space:]]*:/{ser=$NF}
      /(^| )nr_switches[[:space:]]*:/{ns=$NF}
      END{if(ser=="")ser=0;if(ns=="")ns=0; print ser, ns}
    ' "$d/sched" 2>/dev/null || true
  )
  [[ -n "${ser:-}" && -n "${ns:-}" ]] || continue

  art="$(awk -v a="$ser" -v b="$ns" 'BEGIN{if(b+0==0)print 0; else printf "%.6f", a/b}')"

  printf "%s\t%s\t%s\n" "$ppid" "$pid" "$art" >> "$raw"
done

sort -k1,1n "$raw" | awk -F'\t' '{printf "ProcessID=%s : Parent_ProcessID=%s : Average_Running_Time=%s\n", $2, $1, $3}' > art_by_ppid.txt

echo "Done: $(pwd)/art_by_ppid.txt (raw TSV: $(pwd)/art_raw.tsv)"