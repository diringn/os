#!/usr/bin/env bash
set -euo pipefail
touch "$HOME/report"
exec tail -n0 -f "$HOME/report"