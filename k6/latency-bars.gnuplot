#!/usr/bin/env -S gnuplot --persist -c

# Arguments:
infile=ARG1
outfile=ARG2
ptitle=ARG3

stats infile u 0 nooutput

set terminal pngcairo background rgb 'white' linewidth 4 size 1920,1080 enhanced font 'Arial,16'
set output outfile

set title sprintf('%s', ptitle) font 'Arial Bold,20'
set key top right

set border 31 lw 0.5

set tics out
set ylabel 'Latency (ms)'
set ytics
set autoscale y
set yrange [0:*]

set style histogram clustered
set style fill solid
set boxwidth 0.9

set style line 1 lc rgb "#C9190B"
set style line 2 lc rgb "#0066CC"
set style line 3 lc rgb "#009e73"
set style line 4 lc rgb "dark-violet"
set style line 5 lc rgb "gray50"
set style line 6 lc rgb "#0072b2"
set style line 7 lc rgb "dark-green"
set style line 8 lc rgb "#56b4e9"
set style line 9 lc rgb "#e69f00"

plot for [COL=2:STATS_columns] infile using COL:xtic(1) with histograms ls (COL-1) title columnhead