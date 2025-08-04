#!/bin/bash
# Outputs: { "cpu": { "usage": <float> } }

cpu_idle=$(top -bn1 | awk '/Cpu/ {print $8}')
cpu_usage=$(echo "100 - $cpu_idle" | bc)

echo "{\"cpu\": {\"usage\": $cpu_usage}}"
