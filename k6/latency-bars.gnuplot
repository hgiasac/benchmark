#!/usr/bin/env -S gnuplot --persist -c

# Arguments:
infile=ARG1
outfile=ARG2
ptitle=ARG3

set terminal pngcairo background rgb 'white' linewidth 4 size 1920,1080 enhanced font 'Arial,16'
set output outfile

set title sprintf('%s', ptitle) font 'Arial Bold,20'
set key top right

set border 31 lw 0.5

set tics out
set ylabel 'Latency (ms)'
set ytics
set autoscale y

set style histogram clustered
set style fill solid
set boxwidth 0.9

set style line 1 lc rgb "#C9190B"
set style line 2 lc rgb "#0066CC"

plot infile using 2:xtic(1) with histograms ls 1 title columnhead, \
  infile using 3:xtic(1) with histograms ls 2 title columnhead