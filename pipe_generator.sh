#!/usr/bin/env bash
set -euo pipefail
pipe="/home/user/lab3/pipe"
echo "Generator started. Type + | * | <int> | QUIT"
while IFS= read -r line; do
  case "$line" in
    "+"|"*"|"QUIT"|([+-]|)[0-9]*)
        printf '%s\n' "$line" > "$pipe"
        [[ "$line" == "QUIT" ]] && exit 0
        ;;
    *)
        echo "ERROR: invalid input: '$line'"
        printf '%s\n' "$line" > "$pipe"
        exit 1
        ;;
  esac
done