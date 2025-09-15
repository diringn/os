#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab3
kill -TERM "$(cat p3.pid)"
echo "Sent SIGTERM to PID $(cat p3.pid)"