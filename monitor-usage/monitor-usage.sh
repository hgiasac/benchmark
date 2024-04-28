#!/bin/sh
# Usage: ./monitor-usage.sh <PID of the process>
# Output: top.dat with lines such as `1539689171 305000000 2.0`, i.e. unix time - memory in bytes - CPU load in %
PID=$1
OUTPUT="${2:-top.dat}"

# 5s is the default interval between samples.
sint="${BENCH_SAMPLE_INTERVAL:-1}"

rm -f $OUTPUT
while true; do 
  etimes=$(ps -p "$PID" --no-headers -o etimes | awk '{ print $1 }')
  ps -u -p $PID | grep -E '[0-9.]+' | awk -v now=$etimes '{print now,$3,$6}' >> $OUTPUT; 
  sleep $sint
done
