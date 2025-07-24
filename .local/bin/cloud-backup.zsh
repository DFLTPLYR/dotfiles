#!/usr/bin/env bash

function backupMega() {
    if [[ -z "$1" ]]; then
      echo "Usage: backupMegaZip /path/to/folder"
      return 1
    fi

    local folder="$1"
    local foldername=$(basename "$folder")
    local zipfile="/tmp/${foldername}.zip"

    echo "Zipping folder '$folder' to '$zipfile' ..."
    zip -r "$zipfile" "$folder" || {
      echo "Zip failed"
      return 2
    }

    echo "Uploading zipped file to mega:MusicBackup ..."
    rclone copy "$zipfile" mega:MusicBackup/ --progress || {
      echo "Upload failed"
      return 3
    }

    local remote_path="mega:MusicBackup/${foldername}.zip"
    echo "Generating public link for $remote_path ..."
    local link=$(rclone link "$remote_path" 2>/dev/null)

    if [[ -n "$link" ]]; then
      echo "Public link for zipped folder:"
      echo "$link"
    else
      echo "⚠️ Failed to create public link"
    fi


    rm "$zipfile"
}
