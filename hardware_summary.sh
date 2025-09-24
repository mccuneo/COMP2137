#!/bin/bash

echo "--- System Hardware Summary ---"
echo""

echo "Operating System:"
grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME="//;s/"//'

echo "CPU Information:"
grep "model name" /proc/cpuinfo | head -n 1 | awk -F': ' ' {print $2}'
echo ""

echo "RAM Amount:"
grep MemTotal /proc/meminfo | awk '{print $2/1024/1024 " GB"}'
echo ""

