import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
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
        width: Math.round(parent.width)
        height: Math.round(parent.height - cover.height)
        Layout.alignment: Qt.AlignHCenter

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            StyledButton {
                Layout.alignment: Qt.AlignRight
                icon: "\uf04a"
                size: 48
                iconRatio: 0.5
                backgroundColor: Colors.background
                hoverColor: Colors.color15
                iconColor: Colors.color10
                onClicked: MprisManager.togglePlaying()
            }

            StyledButton {
                Layout.alignment: Qt.AlignHCenter
                icon: MprisManager.isPlaying ? "\uf04c" : "\uf04b"
                size: 48
                iconRatio: 0.5
                backgroundColor: Colors.background
                hoverColor: Colors.color15
                iconColor: Colors.color10
                onClicked: MprisManager.togglePlaying()
            }

            StyledButton {
                Layout.alignment: Qt.AlignLeft
                icon: "\uf04e"
                size: 48
                iconRatio: 0.5
                backgroundColor: Colors.background
                hoverColor: Colors.color15
                iconColor: Colors.color10
                onClicked: MprisManager.togglePlaying()
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                Layout.alignment: Qt.AlignHCenter
                text: MprisManager.activeTrack.artist ?? "SYBAU"
                color: Colors.color10
                font.pixelSize: 24
                wrapMode: Text.Wrap
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr(MprisManager.activeTrack.title) ?? "SYBAU"
                color: Colors.color11
                font.pixelSize: 16
                wrapMode: Text.Wrap
                width: Math.round(leftoverArea.width * 0.8)
                horizontalAlignment: Text.AlignHCenter
            }

            ComboBox {
                id: playerDropdown
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.round(leftoverArea.width / 2.5)
                model: MprisManager.availablePlayers.values
                textRole: "identity"
                font.pixelSize: 14

                background: Rectangle {
                    implicitHeight: 36
                    color: Colors.color10
                    radius: 4
                    border.color: playerDropdown.activeFocus ? "#aaa" : "#555"
                    border.width: 1
                }

                contentItem: Text {
                    text: playerDropdown.displayText
                    color: "white"
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                indicator: CustomIcon {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    name: "\uf13a"
                    size: 24
                    color: Colors.color9
                }

                onCurrentIndexChanged: {
                    const selected = model[currentIndex];
                    console.log("Selected player:", selected.identity);
                    MprisManager.setActivePlayer(selected);
                }
            }
        }
    }

    Component.onCompleted: {
        const players = MprisManager.availablePlayers.values;
        for (let i = 0; i < players.length; i++) {
            const player = players[i];
            console.log(`[${i}] - ${player.identity}`);
        }
    }
}
