#!/usr/bin/env bash
set -euo pipefail

BASE="/home/user"
SRC="$BASE/source"
REPORT="$BASE/backup-report"

[[ -d "$SRC" ]] || { echo "Source dir not found: $SRC" >&2; exit 1; }

today="$(date +%F)"
newdir="$BASE/Backup-$today"

last="$(ls -1d "$BASE"/Backup-* 2>/dev/null | sort | tail -n1 || true)"

is_active=0
if [[ -n "$last" ]]; then
  last_date="${last##*-}"
  if date -d "$last_date" >/dev/null 2>&1; then
    now_s="$(date +%s)"
    last_s="$(date -d "$last_date" +%s)"
    diff_days=$(( (now_s - last_s) / 86400 ))
    (( diff_days < 7 )) && is_active=1
  fi
fi

if (( ! is_active )); then
  mkdir -p "$newdir"
  shopt -s nullglob
  copied=()
  for f in "$SRC"/*; do
    [[ -f "$f" ]] || continue
    cp -a -- "$f" "$newdir/"
    copied+=( "$(basename -- "$f")" )
  done
  shopt -u nullglob
  {
    echo "[$(date '+%F %T')] Created $newdir"
    for n in "${copied[@]}"; do echo "  added: $n"; done
  } >> "$REPORT"
  echo "Created new backup: $newdir (report: $REPORT)"
else
  added_new=()
  updated=()
  shopt -s nullglob
  for f in "$SRC"/*; do
    [[ -f "$f" ]] || continue
    base="$(basename -- "$f")"
    dst="$last/$base"
    if [[ ! -e "$dst" ]]; then
      cp -a -- "$f" "$dst"
      added_new+=( "$base" )
    else
      s_src="$(stat -c %s -- "$f")"
      s_dst="$(stat -c %s -- "$dst")"
      if [[ "$s_src" != "$s_dst" ]]; then
        ver="$dst.$today"
        mv -- "$dst" "$ver"
        cp -a -- "$f" "$dst"
        updated+=( "$base $base.$today" )
      fi
    fi
  done
  shopt -u nullglob
  {
    echo "[$(date '+%F %T')] Updated $last"
    for n in "${added_new[@]}"; do echo "  added: $n"; done
    for m in "${updated[@]}";   do echo "  updated: $m"; done
  } >> "$REPORT"
  echo "Updated existing backup: $last (report: $REPORT)"
fi