#!/usr/bin/env zsh
# got the idead from theblackdon
state_file="${XDG_RUNTIME_DIR:-/tmp}/niri-gaming-mode-state"

normal_x=1920
normal_y=0

gaming=2740

if [[ -f $state_file ]]; then
  niri msg output DP-2 position set -- $normal_x $normal_y
  rm -- $state_file
  notify-send "Gaming mode OFF" "Monitors restored to normal positions" -i input-gaming
else
  niri msg output DP-2 position set -- $gaming $gaming
  touch -- $state_file
  notify-send "Gaming mode ON" "Cursor confined to main monitor (DP-1)" -i input-gaming
fi
