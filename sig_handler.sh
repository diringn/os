#!/usr/bin/env bash
set -euo pipefail
echo $$ > /home/user/lab3/.pid
val=1
mode="hold"

usr1() { val=$(( val + 2 )); echo "USR1: +2 => val=$val"; }
usr2() { val=$(( val * 2 )); echo "USR2: *2 => val=$val"; }
on_term() { echo "Stopped by SIGTERM from another process"; exit 0; }

trap 'usr1' USR1
trap 'usr2' USR2
trap 'on_term' TERM

echo "Handler PID=$(cat /home/user/lab3/.pid), start val=$val"
while :; do
  echo "val=$val"
  sleep 1
done