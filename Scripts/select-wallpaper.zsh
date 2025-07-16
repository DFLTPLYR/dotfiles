#!/usr/bin/env bash

# Clean way to suppress fontconfig warnings
exec 2>/dev/null

WALLPAPER_BASE="$HOME/Pictures/wallpaper"
ROFI_THEME="$HOME/.local/share/rofi/themes/style_11.rasi"
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
THUMB_SIZE="300x300"

# Get monitor info in clean format
monitors=$(hyprctl -j monitors | jq -r '.[] | "\(.name) [\(.width)x\(.height)@\(.refreshRate)Hz]"')

# Show selection menu (silencing all warnings)
chosen=$(echo "$monitors" | rofi -dmenu -p "Select monitor" -i -theme $ROFI_THEME)

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
        ;;
    1|3)
        orientation="portrait"
        WALLPAPER_DIR="$WALLPAPER_BASE/portrait"
        ;;
    *)
        orientation="unknown"
        WALLPAPER_DIR="$WALLPAPER_BASE"
        ;;
esac

# Array of wallpapers
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

# Generate image list with preview capability
chosen_wallpaper=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | while read img; do
  echo -e "$(basename "$img")\x00icon\x1f$img"
done | rofi -dmenu -p "Select wallpaper" -i -theme $ROFI_THEME -show-icons)

# Set wallpaper
swww img --outputs "$monitor_name" "$WALLPAPER_DIR/$chosen_wallpaper" --transition-type grow --transition-duration 0.5

# Exit
[[ -z "$chosen_wallpaper" ]] && exit 0
