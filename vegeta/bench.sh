#!/bin/bash

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
ROOT=$(pwd)
OUTPUT_DIR="$ROOT/output"
NAME="${NAME:-result}"
OUTPUT_PATH="$OUTPUT_DIR/$NAME"

mkdir -p $OUTPUT_DIR 

vegeta attack -name=$NAME $@ > "$OUTPUT_PATH.bin"
vegeta plot "$OUTPUT_PATH.bin" > "$OUTPUT_PATH.plot.html"
vegeta report -type=text "$OUTPUT_PATH.bin"
vegeta report -type=hdrplot "$OUTPUT_PATH.bin" > "$OUTPUT_PATH.hgrm"

# plot latency overtime
CHROME_SCREENSHOT_ARGS="--headless --window-size=1920,610 --hide-scrollbars --screenshot=$OUTPUT_DIR/latency.png $OUTPUT_PATH.plot.html"

if command -v google-chrome > /dev/null 2>&1; then
  google-chrome $CHROME_SCREENSHOT_ARGS
elif command -v chromium > /dev/null 2>&1; then
  chromium $CHROME_SCREENSHOT_ARGS
else 
  echo "open $OUTPUT_PATH.plot.html with a web browser to view latency chart"
fi

# plot histogram
../hdrplot/make_percentile_plot -o $OUTPUT_DIR/histogram.png "$OUTPUT_PATH.hgrm" 