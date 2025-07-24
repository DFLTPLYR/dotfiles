#!/bin/bash

last_track=""
while true; do
  artist=$(playerctl metadata artist 2>/dev/null)
  title=$(playerctl metadata title 2>/dev/null)
  arturl=$(playerctl metadata mpris:artUrl 2>/dev/null)

  current_track="$artist – $title"

  # Skip if nothing's playing
  if [[ -z "$artist" || -z "$title" || "$current_track" == " – " ]]; then
    sleep 2
    continue
  fi

  if [[ "$current_track" != "$last_track" ]]; then
    # Handle album art path
    if [[ "$arturl" =~ ^file:// ]]; then
      icon_path="${arturl#file://}"
    elif [[ -f "$arturl" ]]; then
      icon_path="$arturl"
    else
      icon_path="/usr/share/icons/Adwaita/32x32/status/media-playback-start.png"
    fi

    # Send the replaceable notification
    notify-send --app-name="playerctl-track" \
      --hint=string:x-canonical-private-synchronous:nowplaying \
      -i "$icon_path" "Now Playing" "$current_track"

    last_track="$current_track"
  fi

  sleep 2
done
