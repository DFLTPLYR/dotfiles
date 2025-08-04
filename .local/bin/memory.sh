#!/bin/bash

# Use `free -b` to get memory in bytes
mem_line=$(free -b | grep '^Mem:')

# Parse values explicitly using awk
total=$(echo "$mem_line" | awk '{print $2}')
used=$(echo "$mem_line" | awk '{print $3}')
free=$(echo "$mem_line" | awk '{print $4}')
shared=$(echo "$mem_line" | awk '{print $5}')
buff_cache=$(echo "$mem_line" | awk '{print $6}')
available=$(echo "$mem_line" | awk '{print $7}')

# Validate or fallback to zero
total=${total:-0}
used=${used:-0}
free=${free:-0}
shared=${shared:-0}
buff_cache=${buff_cache:-0}
available=${available:-0}

echo "{
  \"memory\": {
    \"total\": $total,
    \"used\": $used,
    \"free\": $free,
    \"available\": $available,
    \"shared\": $shared,
    \"buff_cache\": $buff_cache
  }
}"
