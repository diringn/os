#!/usr/bin/env bash
set -euo pipefail
target=${1:-2.0}
SZ=${2:-8}
work=$(mktemp -d)
measure() {
  rm -f "$work"/file_01.txt
  /home/user/lab6/io_prepare_files.sh 1 "$1" "$work" >/dev/null
  /usr/bin/time -f '%e' /home/user/lab6/io_task.sh "$work/file_01.txt" >/dev/null 2>&1
}
t=$(measure "$SZ")
while awk -v t="$t" -v g="$target" 'BEGIN{exit !(t<g)}'; do
  prevSZ=$SZ; prevT=$t
  SZ=$(( SZ*2 ))
  t=$(measure "$SZ")
done
low=${prevSZ:-$((SZ/2))}; lowt=${prevT:-0.0}
high=$SZ; hight=$t
for _ in $(seq 1 8); do
  mid=$(( (low+high)/2 ))
  (( mid==low )) && break
  tm=$(measure "$mid")
  if awk -v tm="$tm" -v g="$target" 'BEGIN{exit !(tm<g)}'; then
    low=$mid; lowt=$tm
  else
    high=$mid; hight=$tm
  fi
done
echo "Подобрано SIZE_MB ≈ $high (ожидание ~${hight}s) [low=$low ~${lowt}s]"
rm -rf "$work"
