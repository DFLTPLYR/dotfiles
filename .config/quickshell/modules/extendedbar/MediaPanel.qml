import QtQuick
import QtQuick3D
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.Mpris

import qs.services
import qs.components
import qs.assets
import qs.utils
import qs

Rectangle {
    id: wrapper

    anchors.fill: parent
    color: "transparent"

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

    // Album Art
    Rectangle {
        id: albumWrapper
        width: parent.width
        height: width
        color: "transparent"

        Rectangle {
            color: "transparent"
            anchors.centerIn: parent
            width: Math.round(isPortrait ? parent.height : parent.height) - 25
            height: Math.round(isPortrait ? parent.height : parent.height) - 25

            ClippingRectangle {
                width: Math.round(isPortrait ? parent.height : parent.height)
                height: Math.round(isPortrait ? parent.height : parent.height)
                radius: Math.round(isPortrait ? parent.height / 2 : parent.height / 2)

                color: "transparent"

                Image {
                    id: albumArt
                    property real albumRotation: 0
                    property string location: MprisManager.activePlayer ? Qt.resolvedUrl(MprisManager.activePlayer.trackArtUrl) : null
                    source: location
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                    smooth: true
                    width: Math.round(parent.width)
                    height: Math.round(parent.height)
                    sourceSize.width: width
                    sourceSize.height: height
                    rotation: MprisManager.activePlayer.isPlaying ? albumRotation : 0
                }

                FrameAnimation {
                    id: albumRotateFrame
                    running: MprisManager.activePlayer.isPlaying
                    onTriggered: {
                        albumArt.albumRotation += 0.1;
                        if (albumArt.albumRotation > 360)
                            albumArt.albumRotation -= 360;
                    }
                }

                Canvas {
                    anchors.fill: parent
                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        const r = width / 2;
                        ctx.beginPath();
                        ctx.lineWidth = 6;
                        ctx.strokeStyle = Assets.color1;
                        ctx.arc(width / 2, height / 2, r, 0, 2 * Math.PI);
                        ctx.stroke();
                    }
                }

                Canvas {
                    id: progressCanvas
                    anchors.fill: parent
                    property real progress: 0.0

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        const r = width / 2;
                        ctx.beginPath();
                        ctx.lineWidth = 6;
                        ctx.strokeStyle = Assets.color15;
                        ctx.arc(width / 2, height / 2, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * progress);
                        ctx.stroke();
                    }

                    onProgressChanged: requestPaint()
                }

                Connections {
                    id: posChange
                    target: MprisManager.activePlayer
                    function onPositionChanged() {
                        const player = MprisManager.activePlayer;
                        const pos = player?.position;
                        const len = player?.length;

                        const safePos = Math.min(pos, len);
                        const rawProgress = safePos / len;
                        const clampedProgress = Math.min(Math.max(rawProgress, 0), 1);

                        progressCanvas.progress = clampedProgress;
                    }
                }
            }
        }

        Canvas {
            id: cavaBarCanvas
            property var values: wrapper.values

            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter

            visible: MprisManager.activePlayer.isPlaying

            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                const barCount = values.length;
                const centerX = width / 2;
                const centerY = height / 2;
                const radius = width / 2;
                const barLength = width / 6;
                const angleStep = 2 * Math.PI / barCount;

                // Draw base circle
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                ctx.strokeStyle = "transparent";
                ctx.lineWidth = 2;
                ctx.stroke();

                // Draw bars radiating inward from the circle
                for (let i = 0; i < barCount; i++) {
                    const value = values[i];
                    const angle = i * angleStep - Math.PI / 2;
                    const x1 = centerX + Math.cos(angle) * (radius + barLength);
                    const y1 = centerY + Math.sin(angle) * (radius + barLength);
                    const x2 = centerX + Math.cos(angle) * (radius + (1 - value) * barLength);
                    const y2 = centerY + Math.sin(angle) * (radius + (1 - value) * barLength);

                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.strokeStyle = Scripts.setOpacity(Assets.color12, 0.4);
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            }

            Connections {
                target: wrapper
                function onValuesChanged() {
                    cavaBarCanvas.requestPaint();
                }
            }
        }
    }

    // Mpris Details
    Rectangle {
        id: albumDetails

        height: parent.height / 3
        color: "transparent"

        anchors.top: albumWrapper.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Rectangle {
            color: "transparent"
            anchors.centerIn: parent
            width: Math.round(isPortrait ? parent.width : parent.width) - 25
            height: Math.round(isPortrait ? parent.height : parent.height) - 25

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height / 3

                Text {
                    id: artist
                    text: MprisManager.activeTrack.artist ?? "SYBAU"
                    color: Assets.color10
                    font.pixelSize: 24
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    id: title
                    text: qsTr(MprisManager.activeTrack.title) ?? "SYBAU"
                    color: Assets.color11
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    // Controls
    RowLayout {
        id: mprisControls
        anchors.top: albumDetails.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Spacer {}

        StyledButton {
            icon: "\uf04a"
            size: 48
            iconRatio: 0.5
            borderColor: Assets.color10
            backgroundColor: Scripts.setOpacity(Assets.background, 0.4)
            hoverColor: Scripts.setOpacity(Assets.color15, 0.7)
            iconColor: MprisManager.canGoPrevious ? Assets.color10 : Assets.color0
            onClicked: MprisManager.previous()
        }

        StyledButton {
            icon: MprisManager.isPlaying ? "\uf04c" : "\uf04b"
            size: 48
            iconRatio: 0.5
            borderColor: Assets.color10
            backgroundColor: Scripts.setOpacity(Assets.background, 0.4)
            hoverColor: Scripts.setOpacity(Assets.color15, 0.7)
            iconColor: MprisManager.canTogglePlaying ? Assets.color10 : Assets.color0
            onClicked: MprisManager.togglePlaying()
        }

        StyledButton {
            icon: "\uf04e"
            size: 48
            iconRatio: 0.5
            borderColor: Assets.color10
            backgroundColor: Scripts.setOpacity(Assets.background, 0.4)
            hoverColor: Scripts.setOpacity(Assets.color15, 0.7)
            iconColor: MprisManager.canGoNext ? Assets.color10 : Assets.color0
            onClicked: MprisManager.next()
        }

        Spacer {}
    }

    // Other Mpris
    Rectangle {
        anchors.top: mprisControls.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        color: 'transparent'

        RowLayout {
            anchors.centerIn: parent
            visible: Mpris.players.values.length > 1

            Spacer {}

            Repeater {

                model: Mpris.players.values
                delegate: ClippingRectangle {
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: 24
                    radius: width / 2
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: modelData.trackArtUrl
                        fillMode: Image.PreserveAspectCrop
                        cache: true
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: MprisManager.setActivePlayer(modelData)
                    }
                }
            }

            Spacer {}
        }
    }
}
