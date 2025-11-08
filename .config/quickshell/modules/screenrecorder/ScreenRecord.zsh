#!/usr/bin/zsh

# Trap SIGINT (Ctrl+C)
trap 'notify-send -t 2000 -u critical "GPU Screen Recorder" "Recording interrupted!"; exit 130' INT

active_window=$(hyprctl activewindow -j)
if [ -n "$active_window" ] && [ "$active_window" != "null" ]; then
    window_name=$(echo "$active_window" | jq -r '.title // .class // "Unknown"')
else
    window_name="Unknown"
fi

window_name=$(echo "$window_name" | tr '/\\' '_' | tr -d '"')
video_dir="$HOME/Videos/Replays/$window_name"
mkdir -p "$video_dir"
video="$video_dir/$(date +"${window_name}_%Y-%m-%d_%H-%M-%S.mp4")"
mv "$1" "$video"
sleep 0.5 && notify-send -t 2000 -u low "GPU Screen Recorder" "Replay saved to $video"
