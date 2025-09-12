#!/usr/bin/env sh

# Directory where to store temporary data
TMP_DIR="/tmp/rmpc"

# Ensure the directory is created
mkdir -p "$TMP_DIR"

# Where to temporarily store the album art received from rmpc
ALBUM_ART_PATH="$TMP_DIR/notification_cover"

# Path to fallback album art if no album art is found by rmpc/mpd
# Change this to your needs
DEFAULT_ALBUM_ART_PATH="$TMP_DIR/default_album_art.jpg"

# Save album art of the currently playing song to a file
CURRENT_TIME=$(date +%s)
ALBUM_ART_PATH="$TMP_DIR/notification_cover_$CURRENT_TIME"
if ! rmpc albumart --output "$ALBUM_ART_PATH"; then
    # Use default album art if rmpc returns non-zero exit code
    DEFAULT_ALBUM_ART_PATH_UNIQUE="$TMP_DIR/default_album_art_$CURRENT_TIME.jpg"
    cp "$DEFAULT_ALBUM_ART_PATH" "$DEFAULT_ALBUM_ART_PATH_UNIQUE"
    ALBUM_ART_PATH="$DEFAULT_ALBUM_ART_PATH_UNIQUE"
fi

# Send the notification
notify-send -i "${ALBUM_ART_PATH}" "Now Playing" "$ARTIST - $TITLE"
