#!/usr/bin/env bash
set -euo pipefail

TRASH_DIR="$HOME/.trash"
LOG="$HOME/.trash.log"
SEQ="$TRASH_DIR/.seq"
LOCK="$TRASH_DIR/.lock"

usage(){ echo "usage: $0 <filename in current directory>" >&2; exit 1; }
[[ $# -eq 1 ]] || usage

name="$1"

case "$name" in */*) echo "Error: pass just a name (no '/')." >&2; exit 1;; esac
[[ -e "$name" ]] || { echo "Error: file not found: $name" >&2; exit 1; }
[[ -f "$name" ]] || { echo "Error: not a regular file: $name" >&2; exit 1; }
[[ -r "$name" ]] || { echo "Error: no read permission: $name" >&2; exit 1; }

mkdir -p "$TRASH_DIR"

exec 9>>"$LOCK"
flock -x 9
seq_num="$(cat "$SEQ" 2>/dev/null || echo 0)"
seq_num=$((seq_num+1))
printf '%d\n' "$seq_num" > "$SEQ"
flock -u 9

linkname=$(printf '%010d' "$seq_num")

ln -- "$name" "$TRASH_DIR/$linkname"

rm -- "$name"

abs="$(pwd -P)/$name"
printf '%s\0%s\0' "$abs" "$linkname" >> "$LOG"

echo "Moved to trash: $abs  ->  $TRASH_DIR/$linkname"