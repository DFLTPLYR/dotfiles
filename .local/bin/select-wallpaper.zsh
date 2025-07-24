#!/usr/bin/env bash

exec 2>/dev/null

WALLPAPER_BASE="$HOME/Pictures/wallpaper"

rofi_monitor_theme="$HOME/.config/rofi/themes/config-monitor.rasi"
# Array of wallpapers
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

exec 2>/dev/null

regen=false

for arg in "$@"; do
  case "$arg" in
    --regen)
      regen=true
      ;;
  esac
done

if $regen; then
  # Only run this block when --regen is passed
  wallpaper=$(swww query)

  typeset -a wallpapers

  # Loop over the swww query
  while IFS= read -r line; do
    if [[ "$line" == *"image:"* ]]; then
      wallpaper="${line##*image: }"
      wallpapers+=("$wallpaper")
    fi
  done < <(swww query)

  wp1="${wallpapers[1]}"
  wp2="${wallpapers[2]}"

  # Get Temp wallpaper
  temp_wall="/tmp/combined_wallpaper_$$.png"
  convert +append "$wp1" "$wp2" "$temp_wall"

  # Generate colors
  wallust run "$temp_wall"

  # delete temp
  rm -f "$temp_wall"

  pkill swaync && nohup swaync > /dev/null 2>&1 &
  pkill waybar && nohup waybar > /dev/null 2>&1 &

  exit 0
fi

# Get monitor info in clean format
monitors=$(hyprctl -j monitors | jq -r '.[].name')


# Show selection menu (silencing all warnings)
chosen=$(echo "$monitors" | rofi -dmenu -p "Select monitor" -i)

# Exit if nothing selected
[[ -z "$chosen" ]] && exit 0

# Extract just the monitor name (first word)
monitor_name=$(echo "$chosen" | awk '{print $1}')

# Get current transform value
current_transform=$(hyprctl -j monitors | jq -r ".[] | select(.name == \"$monitor_name\") | .transform")

# Determine orientation and set appropriate directory
case $current_transform in
    0|2)
        orientation="landscape"
        WALLPAPER_DIR="$WALLPAPER_BASE/landscape"
        ROFI_THEME="$HOME/.config/rofi/themes/config-wallpaper.rasi"
        ;;
    1|3)
        orientation="portrait"
        WALLPAPER_DIR="$WALLPAPER_BASE/portrait"
        ROFI_THEME="$HOME/.config/rofi/themes/config-wallpaper.rasi"
        ;;
    *)
        orientation="unknown"
        WALLPAPER_DIR="$WALLPAPER_BASE"
        ROFI_THEME="$HOME/.config/rofi/themes/config-wallpaper.rasi"
        ;;
esac

# Generate image list with preview capability
chosen_wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | while read img; do
  echo -e "$(basename "$img")\x00icon\x1f$img"
done | rofi -dmenu -p "Select wallpaper" -i -config $ROFI_THEME)

# Set wallpaper
swww img --outputs "$monitor_name" "$WALLPAPER_DIR/$chosen_wallpaper" --transition-type grow --transition-duration 0.5

# Exit
[[ -z "$chosen_wallpaper" ]] && exit 0
