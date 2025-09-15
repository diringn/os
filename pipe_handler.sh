#!/usr/bin/env bash
set -euo pipefail
pipe="/home/user/lab3/pipe"
mode="add"
acc=1

echo "Handler started (mode=add, acc=1). Waiting on $pipe ..."
while IFS= read -r line; do
  case "$line" in
    "+") mode="add"; echo "Switch to addition";;
    "*") mode="mul"; echo "Switch to multiplication";;
    "QUIT") echo "Planned stop"; exit 0;;
    ''|*[!0-9-+]*)
        echo "ERROR: invalid input: '$line'"; exit 1;;
    *)
        n="$line"
        if [[ "$mode" == "add" ]]; then
          acc=$(( acc + n ))
        else
          acc=$(( acc * n ))
        fi
        echo "ACC=$acc"
        ;;
  esac
done < "$pipe"