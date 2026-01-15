#!/usr/bin/env sh

# Directory where to store temporary data
TMP_DIR="/tmp/rmpc"

# Ensure the directory is created
mkdir -p "$TMP_DIR"

# Path to fallback album art if no album art is found by rmpc/mpd
# Change this to your needs
DEFAULT_ALBUM_ART_PATH="$TMP_DIR/default_album_art.jpg"

# Sanitize album name for filename
ALBUM_CLEAN=$(echo "${ALBUM:-unknown_album}" | sed 's/[^a-zA-Z0-9]/_/g')

# Save album art of the currently playing song to a file
ALBUM_ART_PATH="$TMP_DIR/${ALBUM_CLEAN}_cover.jpg"
if ! rmpc albumart --output "$ALBUM_ART_PATH"; then
  # Use default album art if rmpc returns non-zero exit code
  ALBUM_ART_PATH="$DEFAULT_ALBUM_ART_PATH"
fi

# Send the notification
notify-send -i "${ALBUM_ART_PATH}" "Now Playing" "$ARTIST - $TITLE"
