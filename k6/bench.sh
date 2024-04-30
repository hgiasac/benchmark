#!/bin/bash
# External dependencies:
# - https://stedolan.github.io/jq/
# - https://stedolan.github.io/jq/

set -eEuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
ROOT=$(pwd)

OUTPUT_DIR="$ROOT/output"
NAME="${NAME:-result}"
TITLE="${TITLE:-Benchmark Result}"
OUTPUT_PATH="$OUTPUT_DIR/$NAME"
export SUMMARY_OUTPUT="$OUTPUT_DIR/$NAME.out"

mkdir -p $OUTPUT_DIR

$ROOT/k6bench.sh $@ >"$OUTPUT_PATH.csv"
echo
cat $SUMMARY_OUTPUT
$ROOT/perf.gnuplot "$OUTPUT_PATH.csv" "$OUTPUT_PATH.plot.png" "$TITLE"
$ROOT/../monitor-usage/usage-plot.gp "$OUTPUT_PATH.csv" "$OUTPUT_PATH.usage.png" "$TITLE"
