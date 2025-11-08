#!/bin/bash

STEP=5%
ICON="audio-volume-high"

# Get current volume as integer (first channel only)
get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%'
}

# Clamp volume between 0 and 100
clamp_volume() {
  local vol=$1
  if [ "$vol" -gt 100 ]; then
    vol=100
  elif [ "$vol" -lt 0 ]; then
    vol=0
  fi
  echo "$vol"
}

# Set volume
set_volume() {
  pactl set-sink-volume @DEFAULT_SINK@ "$1%"
}

# Send notification with current volume
send_notification() {
  VOLUME=$(get_volume)
  notify-send --app-name="volume-control" \
    --hint=string:x-canonical-private-synchronous:volume \
    --icon="$ICON" "Volume: $VOLUME%"
}

# Process args
case "$1" in
--inc)
  CURRENT=$(get_volume)
  NEW=$((CURRENT + ${STEP%\%}))
  set_volume "$(clamp_volume "$NEW")"
  # send_notification
  ;;
--dec)
  CURRENT=$(get_volume)
  NEW=$((CURRENT - ${STEP%\%}))
  set_volume "$(clamp_volume "$NEW")"
  # send_notification
  ;;
*)
  echo "Usage: $0 --inc | --dec"
  exit 1
  ;;
esac
