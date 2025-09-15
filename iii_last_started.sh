#!/usr/bin/env bash
set -euo pipefail

pid="$(ps -eo pid=,lstart= --sort=lstart | tail -n 1 | awk '{print $1}')"

echo "$pid"