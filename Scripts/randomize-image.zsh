#!/bin/zsh

logo_dir="$HOME/Pictures/wallpaper/fastfetch"
target_logo="$logo_dir/logo.png"

random_img=$(find "$logo_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.png' \) ! -name "logo.png" | shuf -n 1)

if [[ -n "$random_img" ]]; then
    cp "$random_img" "$target_logo"
    echo "$random_img"   # ✅ return full path
else
    echo "No image found to randomize." >&2
    exit 1
fi
