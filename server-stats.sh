#!/usr/bin/env bash
set -euo pipefail

# CPU usage
read -r _ u1 n1 s1 i1 w1 ir1 si1 st1 _ _ < /proc/stat
t1=$((u1+n1+s1+i1+w1+ir1+si1+st1))
sleep 0.5
read -r _ u2 n2 s2 i2 w2 ir2 si2 st2 _ _ < /proc/stat
t2=$((u2+n2+s2+i2+w2+ir2+si2+st2))
cpu=$(awk -v t1="$t1" -v i1="$i1" -v t2="$t2" -v i2="$i2" 'BEGIN{dt=t2-t1; di=i2-i1; if(dt<=0){print "0.0"} else {printf "%.1f", (1 - di/dt)*100}}')
echo "CPU: ${cpu}%"

# Memory usage
if command -v free >/dev/null 2>&1; then
  free -m | awk '/^Mem:/ {printf "Memory: %s/%s MB (%.1f%%)\n", $3, $2, ($3/$2)*100}'
else
  awk '
    /^MemTotal:/ {total=$2}
    /^MemAvailable:/ {avail=$2}
    END {
      if (total>0) {
        used=(avail>0)?(total-avail):total
        printf "Memory: %.0f/%.0f MB (%.1f%%)\n", used/1024, total/1024, (used/total)*100
      }
    }' /proc/meminfo
fi

# Disk usage
if df -h --total >/dev/null 2>&1; then
  df -h --total | awk 'END{printf "Disk: %s/%s (%s)\n", $3, $2, $5}'
else
  df -k | awk 'NR>1 {used+=$3; size+=$2} END {if(size>0) printf "Disk: %.1fG/%.1fG (%.1f%%)\n", used/1048576, size/1048576, (used/size)*100}'
fi

# Top 5 processes by CPU
echo "Top 5 processes by CPU:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

# Top 5 processes by Memory
echo "Top 5 processes by MEM:"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6
