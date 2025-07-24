#!/bin/bash

# Get counts using pacman-contrib and yay
repo_updates=$(checkupdates 2>/dev/null | wc -l)
aur_updates=$(yay -Qua 2>/dev/null | wc -l)
total=$((repo_updates + aur_updates))

# Nerd Font icon (update arrow)
icon="󰚰"

if [ "$total" -eq 0 ]; then
  echo '{"text": "'"$icon"'", "tooltip": "System up to date"}'
else
  echo '{"text": "'"$icon $total"'", "tooltip": "'"$repo_updates repo, $aur_updates AUR updates available"'"}'
fi
