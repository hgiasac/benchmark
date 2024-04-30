#!/bin/bash

FILES="$@"

LATENCY_OUTPUT=output/latency-comparison
RPS_OUTPUT=output/rps-comparison.png

# export latency comparison
rm -f $LATENCY_OUTPUT.csv $LATENCY_OUTPUT.tmp

echo "Time CPU RAM RPS Mean P90 P95" >> $LATENCY_OUTPUT.tmp

if [ -z "$LEGEND" ]; then
  LEGEND="Name"
  for file in $FILES; do
    LEGEND="$LEGEND $(basename $file)"
  done
fi

for file in $FILES; do
	tail -n 1 $file >> $LATENCY_OUTPUT.tmp
done

../scripts/transpose.sh $LATENCY_OUTPUT.tmp $LATENCY_OUTPUT.tmp2
echo "$LEGEND" > $LATENCY_OUTPUT.csv
tail -n 3 $LATENCY_OUTPUT.tmp2 >> $LATENCY_OUTPUT.csv

rm $LATENCY_OUTPUT.tmp $LATENCY_OUTPUT.tmp2

./latency-bars.gnuplot $LATENCY_OUTPUT.csv $LATENCY_OUTPUT.png

# export RPS comparison
for file in $FILES; do
  if [ -n "$plotcmds" ]; then
    plotcmds="$plotcmds,"
  fi
	plotcmds="$plotcmds '$file' using (\$1):4 with lines title '$(basename $file)'"
done

(
    echo "#plot commands"
    echo "set terminal pngcairo background rgb 'white' linewidth 4 size 1920,1080 enhanced font 'Arial,16'"
    echo "set output '$RPS_OUTPUT'"
		echo "set title 'Latency comparison' font 'Arial Bold,20'"
		echo "set style data lines"
		echo "set style line 100 lt 1 lc rgb 'grey' lw 0.5"
		echo "set grid ls 100"
		echo "set ylabel 'Latency (milliseconds)'"
    echo "set key top left"
    echo "set xlabel 'Time (M:S)'"
    echo "set xdata time"
    echo "set format x '%M:%S'"

    echo "plot $plotcmds"
) | gnuplot
