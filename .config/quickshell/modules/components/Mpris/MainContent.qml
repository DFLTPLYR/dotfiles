import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.services
import qs.modules.components.commons
import qs.assets
import qs

Column {
    anchors.centerIn: parent
    spacing: 25
    anchors.fill: parent
    property bool isPortrait: screen.height > screen.width

    Item {
        id: cover
        width: isPortrait ? parent.width / 1.5 : parent.width / 2
        height: isPortrait ? parent.width / 1.5 : parent.width / 2
        anchors.horizontalCenter: parent.horizontalCenter

        ClippingRectangle {
            anchors.fill: parent
            radius: parent.width / 2
            color: "transparent"

            Image {
                source: MprisManager.activePlayer ? MprisManager.activePlayer.trackArtUrl : null
                fillMode: Image.PreserveAspectCrop
                cache: true
                smooth: true
                mipmap: true
                width: parent.width
                height: parent.height
                sourceSize.width: width
                sourceSize.height: height
            }

            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    const r = width / 2 - 4;
                    ctx.beginPath();
                    ctx.lineWidth = 10;
                    ctx.strokeStyle = Colors.color1;
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
                    const r = width / 2 - 4;
                    ctx.beginPath();
                    ctx.lineWidth = 2;
                    ctx.strokeStyle = Colors.color15;
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

                    // console.log("Clamped progress:", clampedProgress);
                    progressCanvas.progress = clampedProgress;
                }
            }

            // Updates the canvas while playing
            FrameAnimation {
                running: MprisManager.activePlayer.playbackState == MprisPlaybackState.Playing
                onTriggered: MprisManager.activePlayer.positionChanged()
            }
        }
    }

    Column {
        id: leftoverArea
        width: parent.width
        height: parent.height - cover.height
        Layout.alignment: Qt.AlignHCenter

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            PanelToggler {
                Layout.alignment: Qt.AlignRight
                source: Assets.iconPaths.play
                width: 48
                height: 48

                onActivationChanged: MprisManager.previous()
            }

            PanelToggler {
                Layout.alignment: Qt.AlignHCenter
                source: Assets.iconPaths.play
                width: 48
                height: 48
                onActivationChanged: MprisManager.togglePlaying()
            }

            PanelToggler {
                Layout.alignment: Qt.AlignLeft
                source: Assets.iconPaths.play
                width: 48
                height: 48
                onActivationChanged: MprisManager.next()
            }
        }

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                text: MprisManager.activeTrack.artist ?? "SYBAU"
                color: "white"
                font.pixelSize: 16
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: MprisManager.activeTrack.title ?? "SYBAU"
            color: "white"
            font.pixelSize: 16
        }
    }
}
