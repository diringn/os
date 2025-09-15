#!/usr/bin/env bash
set -euo pipefail
sudo systemctl enable --now atd >/dev/null 2>&1 || true
printf '/home/user/lab3/task1.sh\n' | at now + 2 minutes
