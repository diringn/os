#!/usr/bin/env bash
set -euo pipefail

pagesize=$(getconf PAGESIZE 2>/dev/null || getconf PAGE_SIZE)

awk -v pagesize="$pagesize" '
  BEGIN{mt=mf=ma=st=sf="?"}
  $1=="MemTotal:"     {mt=$2}
  $1=="MemFree:"      {mf=$2}
  $1=="MemAvailable:" {ma=$2}
  $1=="SwapTotal:"    {st=$2}
  $1=="SwapFree:"     {sf=$2}
  END{
    printf "MemTotal_kB=%s\nMemFree_kB=%s\nMemAvailable_kB=%s\nSwapTotal_kB=%s\nSwapFree_kB=%s\nPageSize_B=%s\n",
           mt, mf, ma, st, sf, pagesize
  }' /proc/meminfo