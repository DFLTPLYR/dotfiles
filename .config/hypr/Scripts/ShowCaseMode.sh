#!/usr/bin/env bash

# extract the first number from the "custom" field
current=$(hyprctl getoption general:gaps_out -j | jq -r '.custom' | awk '{print $1}')

if [ "$current" -eq 20 ]; then
    # Showcase mode ON
    hyprctl keyword general:gaps_out 200
    hyprctl keyword decoration:rounding 0
else
    # Showcase mode OFF
    hyprctl keyword general:gaps_out 20
    hyprctl keyword decoration:rounding 8
fi
