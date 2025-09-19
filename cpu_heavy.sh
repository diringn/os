#!/usr/bin/env bash
set -euo pipefail
k=${1:?usage: $0 k W}
W=${2:?usage: $0 k W}
start=$((k*W + 1))
end=$(((k+1)*W))
isprime() {
  local n=$1
  ((n>=2)) || return 1
  ((n%2==0)) && { [[ $n -eq 2 ]] && return 0 || return 1; }
  local i=3
  local lim
  lim=$(awk -v n="$n" 'BEGIN{print int(sqrt(n))}')
  while (( i<=lim )); do
    (( n%i==0 )) && return 1
    (( i+=2 ))
  done
  return 0
}
cnt=0
n=$start
(( n%2==0 )) && ((n++))
for (( ; n<=end; n+=2 )); do
  isprime "$n" && ((cnt++))
done
printf "%s %s\n" "$k" "$cnt"