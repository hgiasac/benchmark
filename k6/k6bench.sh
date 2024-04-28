#!/bin/bash
# External dependencies:
# - https://stedolan.github.io/jq/
set -eEuo pipefail

trap 'cleanup; exit 0' EXIT
trap 'trap - INT; cleanup; kill -INT $$' INT
trap 'trap - TERM; cleanup; kill -TERM $$' TERM

# Create temp files to store the output of each collection command.
cpuf=$(mktemp)
memf=$(mktemp)
vusf=$(mktemp)
rpsf=$(mktemp)
medf=$(mktemp)
p90f=$(mktemp)
p95f=$(mktemp)
summaryf=${SUMMARY_OUTPUT:-k6out.txt}

cleanup() {
  rm -f "$cpuf" "$memf" "$vusf" "$rpsf" "$medf" "$p90f" "$p95f"
}

# 5s is the default interval between samples.
# Note that this might be greater if either smem or the k6 API takes more time
# than this to return a response.
sint="${K6_BENCH_SAMPLE_INTERVAL:-5}"

k6 run -q "$@" > "$summaryf" 2>&1 &
k6pid="$!"

PID=${PID:-$k6pid}

# Run the collection processes in parallel to avoid blocking.
# For details see https://stackoverflow.com/a/68316571

# echo '"Time (s)" "CPU (%)" "RAM" "RPS" "Median (ms)" "P90 (ms)" "P95 (ms)"'

while true; do
  etimes=$(ps -p "$k6pid" --no-headers -o etimes | awk '{ print $1 }')
  pids=()
  { exec >"$cpuf"; top -b -n 2 -d "$sint" -p "$PID" | {
      grep "$PID" || echo; } | tail -1 | awk '{print (NF>0 ? $9 : "0")}'; } &
  pids+=($!)
  { exec >"$memf"; 
    if [ command -v smem > /dev/null 2>&1 ] && [ -n "$PROCESSFILTER" ]; then
      smem -H -U "$USER" -c 'pid pss' -P "$PROCESSFILTER" | { grep "$PID" || echo 0; } | awk '{ print $NF }'
    else
      ps -u -p $PID | grep -E '[0-9.]+' | awk '{print $6}' || echo 0
    fi
    } &
  pids+=($!)
  { exec >"$rpsf"; { curl -fsSL http://localhost:6565/v1/metrics/http_reqs 2>/dev/null || echo '{}'
    } | jq '.data.attributes.sample.rate // 0'; } &
  pids+=($!)
  { exec >"$medf"; { curl -fsSL http://localhost:6565/v1/metrics/http_req_duration 2>/dev/null || echo '{}'
    } | jq '.data.attributes.sample.med // 0'; } &
  pids+=($!)
  { exec >"$p90f"; { curl -fsSL http://localhost:6565/v1/metrics/http_req_duration 2>/dev/null || echo '{}'
    } | jq '.data.attributes.sample["p(90)"] // 0'; } &
  pids+=($!)
  { exec >"$p95f"; { curl -fsSL http://localhost:6565/v1/metrics/http_req_duration 2>/dev/null || echo '{}'
    } | jq '.data.attributes.sample["p(95)"] // 0'; } &
  pids+=($!)
  wait "${pids[@]}"
  echo "${etimes} $(cat $cpuf) $(cat "$memf") $(cat $rpsf) $(cat $medf) $(cat $p90f) $(cat $p95f)"
done