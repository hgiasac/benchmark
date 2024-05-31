#!/bin/bash

FILES="$@"

LATENCY_OUTPUT=output/latency-comparison
RPS_OUTPUT=output/rps-comparison.png
CPU_OUTPUT=output/cpu-comparison.png
RAM_OUTPUT=output/ram-comparison.png

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
		echo "set title 'RPS comparison' font 'Arial Bold,20'"
		echo "set style data lines"
		echo "set style line 100 lt 1 lc rgb 'grey' lw 0.5"
		echo "set grid ls 100"
		echo "set ylabel 'RPS'"
    echo "set key top left"
    echo "set xlabel 'Time (M:S)'"
    echo "set xdata time"
    echo "set format x '%M:%S'"

    echo "plot $plotcmds"
) | gnuplot

# export CPU comparison
for file in $FILES; do
  if [ -n "$cpu_plotcmds" ]; then
    cpu_plotcmds="$cpu_plotcmds,"
  fi
	cpu_plotcmds="$cpu_plotcmds '$file' using (\$1):2 with lines title '$(basename $file)'"
done

(
    echo "#plot commands"
    echo "set terminal pngcairo background rgb 'white' linewidth 4 size 1920,1080 enhanced font 'Arial,16'"
    echo "set output '$CPU_OUTPUT'"
		echo "set title 'CPU comparison' font 'Arial Bold,20'"
		echo "set style data lines"
		echo "set style line 100 lt 1 lc rgb 'grey' lw 0.5"
		echo "set grid ls 100"
		echo "set ylabel 'Percent (%)'"
    echo "set key top left"
    echo "set xlabel 'Time (M:S)'"
    echo "set xdata time"
    echo "set format x '%M:%S'"

    echo "plot $cpu_plotcmds"
) | gnuplot

# export memory comparison
for file in $FILES; do
  if [ -n "$ram_plotcmds" ]; then
    ram_plotcmds="$ram_plotcmds,"
  fi
	ram_plotcmds="$ram_plotcmds '$file' using (\$1):(getMemoryBytes(stringcolumn(3))) with lines title '$(basename $file)'"
done

(
    echo "#plot commands"
    echo "set terminal pngcairo background rgb 'white' linewidth 4 size 1920,1080 enhanced font 'Arial,16'"
    echo "set output '$RAM_OUTPUT'"
		echo "set title 'Memory comparison' font 'Arial Bold,20'"
		echo "set style data lines"
		echo "set style line 100 lt 1 lc rgb 'grey' lw 0.5"
		echo "set grid ls 100"
    echo "set ylabel 'Memory usage'"
    echo "set format y '%.1s%cB'"
    echo "set key top left"
    echo "set xlabel 'Time (M:S)'"
    echo "set xdata time"
    echo "set format x '%M:%S'"
    echo "getMemoryBytes(x)=(real(x*1024))"
    echo "plot $ram_plotcmds"
) | gnuplot
