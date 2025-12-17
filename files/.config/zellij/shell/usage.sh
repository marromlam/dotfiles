#!/bin/sh

idle=$(mpstat 1 1 | grep "Average: " | awk '{print $12}')
usage=$(echo "100 - $idle" | bc)
echo "$usage"

