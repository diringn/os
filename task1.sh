#!/usr/bin/env bash
set -euo pipefail

mkdir "$HOME/test" 2>/dev/null \
  && { echo "catalog test was created successfully" >> "$HOME/report";
       touch "$HOME/test/$(date +%F_%H-%M-%S)"; }

ping -c 1 -W 1 www.net_nikogo.ru >/dev/null 2>&1 \
  || echo "$(date '+%F %T') ping error to www.net_nikogo.ru" >> "$HOME/report"
