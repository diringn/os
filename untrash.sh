#!/usr/bin/env bash
set -euo pipefail

TRASH_DIR="$HOME/.trash"
LOG="$HOME/.trash.log"

usage(){ echo "usage: $0 <file name (basename)>" >&2; exit 1; }
[[ $# -eq 1 ]] || usage
target_name="$1"

[[ -r "$LOG" ]] || { echo "Nothing to restore (no $LOG)." >&2; exit 0; }

declare -A restored_ids

while IFS= read -r -d '' path && IFS= read -r -d '' id; do
  base="$(basename -- "$path")"
  [[ "$base" == "$target_name" ]] || continue

  link="$TRASH_DIR/$id"
  if [[ ! -e "$link" ]]; then
    echo "Warning: trash entry missing: $link (skip)" >&2
    continue
  fi

  echo "Found: $path"
  read -r -p "Restore this file? [y/N] " ans
  case "$ans" in
    y|Y|д|Д)
      dest_dir="$(dirname -- "$path")"
      if [[ ! -d "$dest_dir" ]]; then
        echo "Original directory missing; restoring into $HOME"
        dest_dir="$HOME"
      fi

      dest="$dest_dir/$base"
      while [[ -e "$dest" ]]; do
        echo "Path exists: $dest"
        read -r -p "Enter new name (no path): " newname
        case "$newname" in */*|"") echo "Invalid name." ;; *) dest="$dest_dir/$newname";; esac
      done

      if ln -- "$link" "$dest"; then
        rm -- "$link"
        restored_ids["$id"]=1
        echo "Restored to: $dest"
      else
        echo "Error: cannot link to $dest" >&2
      fi
    ;;
    *) : ;;
  esac
done < "$LOG"

if (( ${#restored_ids[@]} )); then
  tmp="$(mktemp)"
  while IFS= read -r -d '' path && IFS= read -r -d '' id; do
    if [[ -z "${restored_ids[$id]:-}" ]]; then
      printf '%s\0%s\0' "$path" "$id" >> "$tmp"
    fi
  done < "$LOG"
  mv -- "$tmp" "$LOG"
fi