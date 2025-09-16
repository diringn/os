#!/usr/bin/env bash
set -euo pipefail
N="${1:-}"
[[ "$N" =~ ^[0-9]+$ ]] || { echo "usage: $0 <N>"; exit 1; }

declare -a A=()
SEQ=(1 2 3 4 5 6 7 8 9 10)
while ((${#A[@]} <= N)); do
  A+=( "${SEQ[@]}" )
done
exit 0