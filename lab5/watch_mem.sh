#!/usr/bin/env bash
set -euo pipefail
cd /home/user/lab5
out="watch_mem.csv"
echo "ts,MemTotal_kB,MemFree_kB,MemAvail_kB,SwapTotal_kB,SwapFree_kB,PID,VSZ_KB,RSS_KB,CPU_PCT,COMMAND" > "$out"

get_mem(){
  awk '
    $1=="MemTotal:"{mt=$2}
    $1=="MemFree:"{mf=$2}
    $1=="MemAvailable:"{ma=$2}
    $1=="SwapTotal:"{st=$2}
    $1=="SwapFree:"{sf=$2}
    END{printf "%s,%s,%s,%s,%s", mt,mf,ma,st,sf}
  ' /proc/meminfo
}

while :; do
  ts=$(date +%F\ %T)

  mapfile -t procs < <(ps -eo pid=,vsz=,rss=,pcpu=,comm=,args= \
     | awk '$5 ~ /^(bash|.*)$/ && $6 ~ /(\/|^)mem(2)?\.bash($| )/ {printf "%s\t%s\t%s\t%s\t%s\n",$1,$2,$3,$4,$6}' )

  sys="$(get_mem)"

  if ((${#procs[@]}==0)); then
    echo "$ts,$sys,,,,," >> "$out"
  else
    for p in "${procs[@]}"; do
      IFS=$'\t' read -r pid vsz rss cpu cmd <<<"$p"
      echo "$ts,$sys,$pid,$vsz,$rss,$cpu,$cmd" >> "$out"
    done
  fi

  sleep 1
done