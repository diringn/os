#!/usr/bin/env bash
set -euo pipefail
F=${1:?usage: $0 file}
[[ -f "$F" ]] || { echo "no file: $F" >&2; exit 1; }
L=$(wc -l < "$F")
head -n "$L" "$F" | while IFS= read -r num; do
  [[ "$num" =~ ^-?[0-9]+$ ]] || continue
  printf "%s\n" $((num*2)) >> "$F"
done