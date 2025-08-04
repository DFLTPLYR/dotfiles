#!/bin/bash
# Outputs: { "network": { "rx_kb": <int>, "tx_kb": <int> } }

read -r rx tx <<< $(cat /proc/net/dev | awk '/^[[:space:]]*e/{gsub(":", "", $1); rx+=$2; tx+=$10} END {print int(rx/1024), int(tx/1024)}')

echo "{
  \"network\": {
    \"rx_kb\": $rx,
    \"tx_kb\": $tx
  }
}"
