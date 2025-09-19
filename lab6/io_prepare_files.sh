#!/usr/bin/env bash
set -euo pipefail
M=${1:?usage: $0 M SIZE_MB [dir]}
SZ_MB=${2:?}
DIR=${3:-/home/user/lab6/data}
mkdir -p "$DIR"
lines=$(( (SZ_MB*1024*1024)/8 ))
for i in $(seq 1 "$M"); do
  f="$DIR/file_$(printf '%02d' "$i").txt"
  awk -v n="$lines" -v s="$i" 'BEGIN{srand(s); for(i=1;i<=n;i++) printf "%d\n", int(1+rand()*1000000000)}' > "$f"
done
echo "Created $M files in $DIR (~${SZ_MB}MB each)"