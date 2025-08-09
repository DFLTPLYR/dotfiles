import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.Mpris

import qs.services
import qs.components
import qs.assets
import qs

GridLayout {
    id: parentGrid
    anchors.fill: parent
    columns: 5
    rows: 5
    rowSpacing: 8
    columnSpacing: 8

    // Date and Clock
    Rectangle {
        color: "#ff9999"

        border.width: 1
        border.color: Colors.color1
        radius: 10

        Layout.row: 0
        Layout.column: 0
        Layout.rowSpan: 5
        Layout.minimumWidth: 80
        Layout.preferredWidth: Math.round(parent.width / 5)
        Layout.fillHeight: true
        Text {
            anchors.centerIn: parent
            text: "1"
        }
    }

    // System data
    Rectangle {
        color: "#99ff99"

        border.width: 1
        border.color: Colors.color1
        radius: 10

        Layout.row: 0
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.rowSpan: 2
        Layout.fillWidth: true
        Layout.fillHeight: true
        Text {
            anchors.centerIn: parent
            text: "2"
        }
    }

    // Mpris
    Rectangle {
        color: "transparent"

        border.width: 1
        border.color: Colors.color1
        radius: 10

        Layout.row: 0
        Layout.column: 4
        Layout.rowSpan: 5
        Layout.minimumWidth: 80
        Layout.preferredWidth: Math.round(parent.width / 5)
        Layout.fillHeight: true

        Rectangle {
            id: albumWrapper
            width: parent.width
            height: width
            color: "transparent"

            ClippingRectangle {
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
                        source: MprisManager.activePlayer ? MprisManager.activePlayer.trackArtUrl : null
                        fillMode: Image.PreserveAspectCrop
                        cache: true
                        smooth: true
                        mipmap: true
                        width: Math.round(parent.width)
                        height: Math.round(parent.height)
                        sourceSize.width: width
                        sourceSize.height: height
                    }

                    Canvas {
                        anchors.fill: parent
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            const r = width / 2;
                            ctx.beginPath();
                            ctx.lineWidth = 6;
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
                            const r = width / 2;
                            ctx.beginPath();
                            ctx.lineWidth = 6;
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

                            progressCanvas.progress = clampedProgress;
                        }
                    }

                    FrameAnimation {
                        running: MprisManager.activePlayer.playbackState == MprisPlaybackState.Playing
                        onTriggered: MprisManager.activePlayer.positionChanged()
                    }
                }
            }
        }

        Rectangle {
            id: albumDetails
            color: "transparent"
            anchors.top: albumWrapper.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height / 3

            ClippingRectangle {
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
                        color: Colors.color10
                        font.pixelSize: 24
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        id: title
                        text: qsTr(MprisManager.activeTrack.title) ?? "SYBAU"
                        color: Colors.color11
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

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
                backgroundColor: Colors.background
                hoverColor: Colors.color15
                iconColor: Colors.color10
                onClicked: MprisManager.previous()
            }

            StyledButton {
                icon: MprisManager.isPlaying ? "\uf04c" : "\uf04b"
                size: 48
                iconRatio: 0.5
                backgroundColor: Colors.background
                hoverColor: Colors.color15
                iconColor: Colors.color10
                onClicked: MprisManager.togglePlaying()
            }

            StyledButton {
                icon: "\uf04e"
                size: 48
                iconRatio: 0.5
                backgroundColor: Colors.background
                hoverColor: Colors.color15
                iconColor: Colors.color10
                onClicked: MprisManager.next()
            }

            Spacer {}
        }

        Rectangle {

            anchors.top: mprisControls.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            color: 'transparent'

            RowLayout {
                anchors.centerIn: parent

                Spacer {}

                Repeater {
                    model: Mpris.players.values
                    delegate: Rectangle {
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
                            mipmap: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: MprisManager.activePlayer = modelData
                        }
                    }
                }

                Spacer {}
            }
        }
    }

    // Calendar
    Rectangle {
        color: "#ffff99"

        border.width: 1
        border.color: Colors.color1
        radius: 10

        Layout.row: 2
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.rowSpan: 3
        Layout.fillWidth: true
        Layout.fillHeight: true
        Text {
            anchors.centerIn: parent
            text: "4"
        }
    }
}
