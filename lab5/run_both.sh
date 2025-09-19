#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab5
: > report.log
: > report2.log
./mem.bash  & echo "mem.bash  PID=$!"
./mem2.bash & echo "mem2.bash PID=$!"
