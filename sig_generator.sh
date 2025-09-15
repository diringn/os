#!/usr/bin/env bash
set -euo pipefail
pidfile="/home/user/lab3/.pid"
while [[ ! -s "$pidfile" ]]; do sleep 0.1; done
PID="$(cat "$pidfile")"
echo "Generator: target PID=$PID. Type + | * | TERM"
while IFS= read -r line; do
  case "$line" in
    "+")   kill -USR1 "$PID" ;;
    "*")   kill -USR2 "$PID" ;;
    "TERM") kill -TERM "$PID"; exit 0 ;;
    *)     : ;;
  done
done