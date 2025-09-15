#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab2

[[ -f art_raw.tsv ]] || /home/user/lab2/iv_art_by_ppid.sh >/dev/null

sort -k1,1n art_raw.tsv | awk -F'\t' '
BEGIN { pp=-1; sum=0; cnt=0; }
{
  if (pp!=-1 && $1!=pp) {
    printf "Average_Running_Children_of_ParentID=%d is %.6f\n", pp, (cnt?sum/cnt:0)
    sum=0; cnt=0
  }
  printf "ProcessID=%s : Parent_ProcessID=%s : Average_Running_Time=%s\n", $2, $1, $3
  pp=$1; sum+=($3+0); cnt++
}
END {
  if (pp!=-1) {
    printf "Average_Running_Children_of_ParentID=%d is %.6f\n", pp, (cnt?sum/cnt:0)
  }
}
' > art_by_ppid_with_avg.txt

echo "Done: $(pwd)/art_by_ppid_with_avg.txt"