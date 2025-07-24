#!/usr/bin/env zsh
pkill waybar
nohup waybar > ~/.cache/waybar.log 2>&1 &
