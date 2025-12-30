#!/usr/bin/zsh

pidof -q gpu-screen-recorder && exit 0
video_path="$HOME/Videos"
mkdir -p "$video_path"
script_dir="$(dirname "$(realpath "$0")")"
gpu-screen-recorder -w screen -f 60 -a default_output -r 60 -sc "$script_dir/ScreenRecord.zsh" -c mp4 -o "$video_path"
