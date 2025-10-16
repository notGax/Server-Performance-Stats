#!/usr/bin/env bash

# CPU (delta from /proc/stat with a tiny sleep)
awk 'BEGIN{
  getline <"/proc/stat"; split($0,a)
  t1=a[2]+a[3]+a[4]+a[5]+a[6]+a[7]+a[8]+a[9]; i1=a[5]
  system("sleep 0.5")
  getline <"/proc/stat"; split($0,b)
  t2=b[2]+b[3]+b[4]+b[5]+b[6]+b[7]+b[8]+b[9]; i2=b[5]
  printf "CPU: %.1f%%\n", (1- (i2-i1)/(t2-t1))*100
}'

# Memory (MB)
free -m | awk '/^Mem:/ {printf "Memory: %s/%s MB (%.1f%%)\n", $3, $2, ($3/$2)*100}'

# Disk (all filesystems total)
df -h --total | awk 'END{printf "Disk: %s/%s (%s)\n", $3, $2, $5}'

# Top 5 by CPU
echo "Top 5 processes by CPU:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

# Top 5 by MEM
echo "Top 5 processes by MEM:"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6
