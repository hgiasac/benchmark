#!/usr/bin/env -S gnuplot --persist -c
# Plot memory and CPU usage over time. Usage:
#  usage-plot.gp <input file> [<output .png file>]
# where the input file has the columns `<unix time> <memory, with m/g suffix> <% cpu>`
# To create the input file, see https://gist.github.com/jakubholynet/931a3441982c833f5f8fcdcf54d05c91

# Arguments:
infile=ARG1
outfile=ARG2
title=ARG3
if (!exists("ARG3")) {
  title='benchmark'
}

set term x11
set title 'Memory, CPU usage from ' . title font 'Arial Bold,20'

set border 31 lw 0.5
set style data lines
set style line 100 lt 1 lc rgb "grey" lw 0.5 # linestyle for the grid
set grid ls 100

set xdata time
set timefmt "%s"
set xlabel 'Time (M:S)'
set autoscale x

set ylabel "Memory usage"
set format y '%.1s%cB'

set y2label 'CPU (%)'
set format y2 '%.1f%%'
set y2tics nomirror
set tics out
set autoscale y
set autoscale y2

getMemoryBytes(x)=(real(x*1024))

if (exists("outfile") && strlen(outfile) > 0) {
    print "Exporing usage plot to the file ", outfile
    set term pngcairo background rgb 'white' linewidth 4 size 1920,1080 enhanced font 'Arial,16'
    set output outfile
}

# Styling
set style line 1 linewidth 1 linecolor 'light-red'
set style line 2 linewidth 0.5 linecolor 'blue'
set xtics rotate # put label every 60s, make vertical so they don't clash in .png if too many

plot infile u 1:2 with lp axes x1y2 title "CPU" linestyle 2, \
    infile using 1:(getMemoryBytes(stringcolumn(3))) with lp title "RAM" linestyle 1
