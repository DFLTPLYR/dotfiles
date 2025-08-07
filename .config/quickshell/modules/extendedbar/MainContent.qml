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
        spacing: 10

        ComboBox {
            id: playerDropdown
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(leftoverArea.width / 2.5)
            model: MprisManager.availablePlayers.values
            textRole: "identity"
            font.pixelSize: 14
            padding: 2

            delegate: ItemDelegate {
                id: delegate

                required property var model
                required property int index

                width: Math.round(playerDropdown.width)

                contentItem: Text {
                    text: delegate.model[playerDropdown.textRole]
                    color: Colors.color10
                    font: playerDropdown.font
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                highlighted: playerDropdown.highlightedIndex === index
            }

            background: Rectangle {
                color: Colors.color10
                radius: 50
            }

            contentItem: Text {
                text: playerDropdown.displayText
                color: "white"
                font.pixelSize: 24
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            indicator: CustomIcon {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 8
                name: "\uf13a"
                size: 32
                color: Colors.color9
            }

            popup: Popup {
                y: Math.round(playerDropdown.height - 1)
                width: Math.round(playerDropdown.width)
                height: Math.min(contentItem.implicitHeight, playerDropdown.Window.height - topMargin - bottomMargin)
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: playerDropdown.popup.visible ? playerDropdown.delegateModel : null
                    currentIndex: playerDropdown.highlightedIndex

                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                background: Rectangle {
                    color: Colors.background
                    border.color: Colors.background
                    radius: 2
                }
            }

            onCurrentIndexChanged: {
                const selected = model[currentIndex];
                MprisManager.setActivePlayer(selected);
            }
        }

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
