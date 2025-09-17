#!/usr/bin/env bash
set -euo pipefail
target=${1:-2.0}
W=${2:-200000}
measure() {
  /usr/bin/time -f '%e' /home/user/lab6/cpu_heavy.sh 0 "$1" >/dev/null 2>&1
}
t=$(measure "$W")
while awk -v t="$t" -v g="$target" 'BEGIN{exit !(t<g)}'; do
  prevW=$W; prevT=$t
  W=$(( W*2 ))
  if (( W <= 0 )); then echo "W overflow, выбери меньше старт"; exit 1; fi
  t=$(measure "$W")
done
low=${prevW:-$((W/2))}; lowt=${prevT:-0.0}
high=$W; hight=$t
for _ in $(seq 1 10); do
  mid=$(( (low+high)/2 ))
  (( mid==low )) && break
  tm=$(measure "$mid")
  if awk -v tm="$tm" -v g="$target" 'BEGIN{exit !(tm<g)}'; then
    low=$mid; lowt=$tm
  else
    high=$mid; hight=$tm
  fi
done
echo "Подобрано W ≈ $high (ожидание ~${hight}s) [low=$low ~${lowt}s]"
