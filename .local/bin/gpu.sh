#!/bin/bash

# Exit on any failure
set -e

# Check if amdgpu_top exists
if ! command -v amdgpu_top &> /dev/null; then
    echo '{"gpu": null}'
    exit 0
fi

# Collect JSON output (1 snapshot only)
gpu_json=$(amdgpu_top -J -n 1 2>/dev/null || echo "")

# Return null if command fails
if [ -z "$gpu_json" ]; then
    echo '{"gpu": null}'
    exit 0
fi

# Parse values using jq
usage=$(echo "$gpu_json" | jq '.[] | select(.name == "GPU Load (%)") | .value')
vram_used=$(echo "$gpu_json" | jq '.[] | select(.name == "VRAM Usage (MB)") | .value')
vram_total=$(echo "$gpu_json" | jq '.[] | select(.name == "VRAM Total (MB)") | .value')

# Check all values are numeric
if [[ ! "$usage" =~ ^[0-9]+$ ]] || [[ ! "$vram_used" =~ ^[0-9]+$ ]] || [[ ! "$vram_total" =~ ^[0-9]+$ ]]; then
    echo '{"gpu": null}'
    exit 0
fi

# Output JSON
echo "{
  \"gpu\": {
    \"usage\": $usage,
    \"memory_used\": $vram_used,
    \"memory_total\": $vram_total
  }
}"
