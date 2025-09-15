#!/usr/bin/env bash
set -euo pipefail

BASE="/home/user"
RESTORE="$BASE/restore"
mkdir -p "$RESTORE"

latest="$(ls -1d "$BASE"/Backup-* 2>/dev/null | sort | tail -n1 || true)"
[[ -n "$latest" ]] || { echo "No backups found." >&2; exit 1; }

shopt -s nullglob
for f in "$latest"/*; do
  [[ -f "$f" ]] || continue
  base="$(basename -- "$f")"
  if [[ "$base" =~ \.[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    continue
  fi
  cp -a -- "$f" "$RESTORE/$base"
done
shopt -u nullglob

echo "Restored files from $latest to $RESTORE"