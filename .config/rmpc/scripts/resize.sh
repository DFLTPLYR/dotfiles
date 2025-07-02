#!/usr/bin/env bash

# notify-send "Current rows: $ROWS"

if (( ROWS < 50 )); then
    rmpc remote --pid "$PID" set config /home/dfltplyr/.config/rmpc/layout/config.ron
elif (( ROWS <= 75 )); then
    rmpc remote --pid "$PID" set config /home/dfltplyr/.config/rmpc/layout/medium.ron
else
    rmpc remote --pid "$PID" set config /home/dfltplyr/.config/rmpc/layout/long.ron
fi
