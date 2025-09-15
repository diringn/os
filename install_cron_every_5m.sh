#!/usr/bin/env bash
set -euo pipefail
DOW="${1:-$(date +%w)}"
( crontab -l 2>/dev/null; echo "*/5 * * * $DOW /home/user/lab3/task1.sh" ) | crontab -
echo "Put: */5 * * * $DOW /home/user/lab3/task1.sh"
