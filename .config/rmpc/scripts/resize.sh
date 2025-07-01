#!/usr/bin/env bash

notify-send "Current rows: $ROWS"

if (( ROWS < 50 )); then
    rmpc remote --pid "$PID" set config /home/dfltplyr/.config/rmpc/layout/config.ron
    notify-send "Small config applied"
elif (( ROWS <= 75 )); then
    rmpc remote --pid "$PID" set config /home/dfltplyr/.config/rmpc/layout/medium.ron
    notify-send "Medium config applied"
else
    rmpc remote --pid "$PID" set config /home/dfltplyr/.config/rmpc/layout/long.ron
    notify-send "Long config applied"
fi
