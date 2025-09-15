#!/usr/bin/env bash
set -euo pipefail
DIR=${1:?usage: $0 DIR}
out=/home/user/lab6/io_seq_times.csv
echo "N,run,seconds" > "$out"
for N in $(seq 1 20); do
  for r in $(seq 1 10); do
    tmp=$(mktemp -d)
    cp -a "$DIR"/* "$tmp"/
    t=$(/usr/bin/time -f '%e' /home/user/lab6/run_io_seq.sh "$N" "$tmp" 2>&1 >/dev/null)
    printf "%d,%d,%s\n" "$N" "$r" "$t" >> "$out"
    rm -rf "$tmp"
  done
done
awk -F, 'NR>1{sum[$1]+=$3;cnt[$1]++} END{print "N,mean_seconds"; for(n=1;n<=20;n++) if(cnt[n]) printf "%d,%.6f\n", n, sum[n]/cnt[n]}' "$out" > /home/user/lab6/io_seq_mean.csv
echo "OK: io_seq_times.csv, io_seq_mean.csv"