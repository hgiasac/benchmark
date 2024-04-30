#!/usr/bin/env -S gnuplot --persist -c

# Arguments:
infile=ARG1
outfile=ARG2
ptitle=ARG3

set terminal pngcairo background rgb 'white' linewidth 4 size 1920,1080 enhanced font 'Arial,16'
set bmargin at screen 130.0/1080
set rmargin at screen 1080.0/1920
set output outfile

set title sprintf('%s', ptitle) font 'Arial Bold,20'
set key center right

set border 31 lw 0.5
set style data lines
set style line 100 lt 1 lc rgb "grey" lw 0.5 # linestyle for the grid
set grid ls 100

set xlabel 'Time (M:S)'
set xdata time
set format x '%M:%S'
set xtics rotate
set ylabel 'Latency (ms)'
set ytics
set autoscale x
set autoscale y
set y2label "RPS"
set y2tics
set tics out
set autoscale y2

set style line 2 linewidth 0.5

checkEmpty(x)=((x == 0) ? (1/0) : x)

plot infile using ($1):4 axis x1y2 title "RPS", \
  infile using ($1):5 axis x1y1 title "Median", \
  infile using ($1):6 axis x1y1 title "P90", \
  infile using ($1):7 axis x1y1 title "P95"