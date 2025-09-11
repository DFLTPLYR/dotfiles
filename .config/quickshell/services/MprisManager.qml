pragma Singleton
pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs

Singleton {
    id: root
    property MprisPlayer trackedPlayer: null
    property MprisPlayer activePlayer: trackedPlayer ?? Mpris.players.values[0] ?? null
    signal trackChanged(reverse: bool)

    property bool __reverse: false

    property var activeTrack

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: {
                if (root.trackedPlayer == null || modelData.isPlaying) {
                    root.trackedPlayer = modelData;
                }
            }

            Component.onDestruction: {
                if (root.trackedPlayer == null || !root.trackedPlayer.isPlaying) {
                    for (const player of Mpris.players.values) {
                        if (player.playbackState.isPlaying) {
                            root.trackedPlayer = player;
                            break;
                        }
                    }

                    if (trackedPlayer == null && Mpris.players.values.length != 0) {
                        trackedPlayer = Mpris.players.values[0];
                    }
                }
            }

            function onPlaybackStateChanged() {
                if (root.trackedPlayer !== modelData)
                    root.trackedPlayer = modelData;
            }
        }
    }

    Connections {
        target: activePlayer

        function onPostTrackChanged() {
            root.updateTrack();
        }

        function onTrackArtUrlChanged() {
            console.log("arturl:", activePlayer.trackArtUrl);
            //root.updateTrack();
            if (root.activePlayer.uniqueId == root.activeTrack.uniqueId && root.activePlayer.trackArtUrl != root.activeTrack.artUrl) {
                // cantata likes to send cover updates *BEFORE* updating the track info.
                // as such, art url changes shouldn't be able to break the reverse animation
                const r = root.__reverse;
                root.updateTrack();
                root.__reverse = r;
            }
        }
    }

    onActivePlayerChanged: this.updateTrack()

    function updateTrack() {
        this.activeTrack = {
            uniqueId: this.activePlayer?.uniqueId ?? 0,
            artUrl: this.activePlayer?.trackArtUrl ?? "",
            title: this.activePlayer?.trackTitle || "Unknown Title",
            artist: this.activePlayer?.trackArtist || "Unknown Artist",
            album: this.activePlayer?.trackAlbum || "Unknown Album"
        };

        this.trackChanged(__reverse);
        this.__reverse = false;
    }

    property bool isPlaying: this.activePlayer && this.activePlayer.isPlaying
    property bool canTogglePlaying: this.activePlayer?.canTogglePlaying ?? false
    function togglePlaying() {
        if (this.canTogglePlaying)
            this.activePlayer.togglePlaying();
    }

    property bool canGoPrevious: this.activePlayer?.canGoPrevious ?? false
    function previous() {
        if (this.canGoPrevious) {
            this.__reverse = true;
            this.activePlayer.previous();
        }
    }

    property bool canGoNext: this.activePlayer?.canGoNext ?? false
    function next() {
        if (this.canGoNext) {
            this.__reverse = false;
            this.activePlayer.next();
        }
    }

    property bool canChangeVolume: this.activePlayer && this.activePlayer.volumeSupported && this.activePlayer.canControl

    function setActivePlayer(player: MprisPlayer) {
        const targetPlayer = player ?? Mpris.players[0];
        if (targetPlayer && this.activePlayer) {
            this.__reverse = Mpris.players.indexOf(targetPlayer) < Mpris.players.indexOf(this.activePlayer);
        } else {
            // always animate forward if going to null
            this.__reverse = false;
        }

        this.trackedPlayer = targetPlayer;
    }

    IpcHandler {
        target: "mpris"

        function pauseAll(): void {
            for (const player of Mpris.players.values) {
                if (player.canPause)
                    player.pause();
            }
        }

        function playPause(): void {
            root.togglePlaying();
        }
        function previous(): void {
            root.previous();
        }
        function next(): void {
            root.next();
        }
    }

    // cava
    property int count: 256
    property int noiseReduction: 60
    property string channels: "stereo"
    property string monoOption: "average"
    property var config: ({
            general: {
                bars: count
            },
            smoothing: {
                noise_reduction: noiseReduction
            },
            output: {
                method: "raw",
                bit_format: 8,
                channels: channels,
                mono_option: monoOption
            }
        })

    property var values: Array(count).fill(0)

    onConfigChanged: {
        process.running = false;
        process.running = true;
    }

    Process {
        id: process
        property int index: 0
        stdinEnabled: true
        command: ["cava", "-p", "/dev/stdin"]
        onExited: {
            stdinEnabled = true;
            index = 0;
        }
        onStarted: {
            const iniParts = [];
            for (const k in config) {
                if (typeof config[k] !== "object") {
                    write(k + "=" + config[k] + "\n");
                    continue;
                }
                write("[" + k + "]\n");
                const obj = config[k];
                for (const k2 in obj) {
                    write(k2 + "=" + obj[k2] + "\n");
                }
            }
            stdinEnabled = false;
        }
        stdout: SplitParser {
            property var newValues: Array(count).fill(0)
            splitMarker: ""
            onRead: data => {
                const length = config.general.bars;
                if (process.index + data.length > length) {
                    process.index = 0;
                }
                for (let i = 0; i < data.length; i += 1) {
                    const newIndex = i + process.index;
                    if (newIndex > length) {
                        break;
                    }
                    newValues[newIndex] = Math.min(data.charCodeAt(i), 128) / 128;
                }
                process.index += data.length;
                values = newValues;
            }
        }
    }
}
