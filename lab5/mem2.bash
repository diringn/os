#!/usr/bin/env bash
set -u
cd /home/user/lab5
: > report2.log
declare -a A=(); step=0
SEQ=(1 2 3 4 5 6 7 8 9 10)
while :; do
  A+=( "${SEQ[@]}" )
  ((step++))
  if (( step % 100000 == 0 )); then
    echo "${#A[@]}" >> report2.log
  fi
done
