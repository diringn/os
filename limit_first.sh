#!/usr/bin/env bash

set -euo pipefail
cd /home/user/lab3
PID="$(cat p1.pid)"
echo "Control PID=$PID (target <=10% CPU)"
while kill -0 "$PID" 2>/dev/null; do
  cpu="$(ps -p "$PID" -o %cpu= 2>/dev/null | awk '{print int($1+0.5)}')"
  if (( cpu > 10 )); then
    kill -STOP "$PID" 2>/dev/null || true
    sleep 0.25
  else
    kill -CONT "$PID" 2>/dev/null || true
    sleep 0.75
  fi
done
echo "PID $PID finished"