#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab3
./busy_worker.sh & echo $! > p1.pid
./busy_worker.sh & echo $! > p2.pid
./busy_worker.sh & echo $! > p3.pid
echo "PIDs: $(cat p1.pid) $(cat p2.pid) $(cat p3.pid)"
