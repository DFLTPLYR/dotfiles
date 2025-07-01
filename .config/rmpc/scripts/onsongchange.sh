#!/usr/bin/env sh

# Get the current file path from MPD
FILE=$(mpc --format %file% current)

# Sanity check: is MPD playing anything?
if [ -z "$FILE" ]; then
    echo "No file currently playing."
    exit 1
fi

# Confirm MPD has this file in the DB
if ! mpc search filename "$FILE" | grep -Fxq "$FILE"; then
    echo "MPD does not recognize the file: $FILE"
    exit 1
fi

# Get existing playCount sticker
sticker=$(rmpc sticker get "$FILE" playCount 2>/dev/null | jq -r '.value')

# If no sticker yet or value is invalid
if [ -z "$sticker" ] || ! echo "$sticker" | grep -qE '^[0-9]+$'; then
    rmpc sticker set "$FILE" playCount 1
    echo "Initialized playCount to 1 for: $FILE"
else
    new_count=$((sticker + 1))
    rmpc sticker set "$FILE" playCount "$new_count"
    echo "playCount updated to $new_count for: $FILE"
fi

LRCLIB_INSTANCE="https://lrclib.net"

if [ "$HAS_LRC" = "false" ]; then
    mkdir -p "$(dirname "$LRC_FILE")"

    LYRICS="$(curl -X GET -sG \
        -H "Lrclib-Client: rmpc-$VERSION" \
        --data-urlencode "artist_name=$ARTIST" \
        --data-urlencode "track_name=$TITLE" \
        --data-urlencode "album_name=$ALBUM" \
        "$LRCLIB_INSTANCE/api/get" | jq -r '.syncedLyrics')"

    if [ -z "$LYRICS" ]; then
        rmpc remote --pid "$PID" status "Failed to download lyrics for $ARTIST - $TITLE" --level error
        exit
    fi

    if [ "$LYRICS" = "null" ]; then
        rmpc remote --pid "$PID" status "Lyrics for $ARTIST - $TITLE not found" --level warn
        exit
    fi

    echo "[ar:$ARTIST]" >"$LRC_FILE"
    {
        echo "[al:$ALBUM]"
        echo "[ti:$TITLE]"
    } >>"$LRC_FILE"
    echo "$LYRICS" | sed -E '/^\[(ar|al|ti):/d' >>"$LRC_FILE"

    rmpc remote --pid "$PID" indexlrc --path "$LRC_FILE"
    rmpc remote --pid "$PID" status "Downloaded lyrics for $ARTIST - $TITLE" --level info
fi
