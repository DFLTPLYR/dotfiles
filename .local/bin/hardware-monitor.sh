#!/bin/sh
while true; do
  (cpu.sh; network.sh; memory.sh) | jq -s add -c
  sleep 1
done
