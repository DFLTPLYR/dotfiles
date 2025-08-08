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
    anchors.fill: parent
    spacing: 20

    GridLayout {
        height: (parent.height - 2 * parent.spacing) / 3
        width: parent.width
        Row {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    GridLayout {
        height: (parent.height - 2 * parent.spacing) / 3
        width: parent.width
        Row {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        // ComboBox {
        //     id: playerDropdown
        //     width: 50
        //     model: MprisManager.availablePlayers.values
        //     textRole: "identity"
        //     font.pixelSize: 3
        //     // padding: 2

        //     delegate: ItemDelegate {
        //         id: delegate

        //         required property var model
        //         required property int index

        //         width: Math.round(playerDropdown.width)

        //         contentItem: Text {
        //             text: delegate.model[playerDropdown.textRole]
        //             color: Colors.color10
        //             font: playerDropdown.font
        //             elide: Text.ElideRight
        //             verticalAlignment: Text.AlignVCenter
        //         }
        //         highlighted: playerDropdown.highlightedIndex === index
        //     }

        //     background: Rectangle {
        //         color: Colors.color10
        //         radius: 50
        //     }

        //     contentItem: Text {
        //         text: playerDropdown.displayText
        //         color: "white"
        //         font.pixelSize: 24
        //         verticalAlignment: Text.AlignVCenter
        //         elide: Text.ElideRight
        //     }

        //     indicator: CustomIcon {
        //         anchors.right: parent.right
        //         anchors.verticalCenter: parent.verticalCenter
        //         anchors.rightMargin: 8
        //         name: "\uf13a"
        //         size: 32
        //         color: Colors.color9
        //     }

        //     popup: Popup {
        //         y: Math.round(playerDropdown.height - 1)
        //         width: Math.round(playerDropdown.width)
        //         height: Math.min(contentItem.implicitHeight, playerDropdown.Window.height - topMargin - bottomMargin)
        //         padding: 1

        //         contentItem: ListView {
        //             clip: true
        //             implicitHeight: contentHeight
        //             model: playerDropdown.popup.visible ? playerDropdown.delegateModel : null
        //             currentIndex: playerDropdown.highlightedIndex

        //             ScrollIndicator.vertical: ScrollIndicator {}
        //         }

        //         background: Rectangle {
        //             color: Colors.background
        //             border.color: Colors.background
        //             radius: 2
        //         }
        //     }

        //     onCurrentIndexChanged: {
        //         const selected = model[currentIndex];
        //         MprisManager.setActivePlayer(selected);
        //     }
        // }
    }

    GridLayout {
        id: layout
        width: parent.width
        height: (parent.height - 2 * parent.spacing) / 3
        columns: 2
        columnSpacing: 0
        rowSpacing: 0

        Item {
            id: squareWrapper
            Layout.row: 0
            Layout.column: 0
            Layout.preferredWidth: layout.height
            Layout.fillHeight: true

            Rectangle {
                anchors.fill: parent
                color: "transparent"

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
            Layout.row: 0
            Layout.column: 1
            Layout.fillHeight: true
            Layout.preferredWidth: layout.width - squareWrapper.width
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: 2

                Text {
                    id: artistText
                    text: MprisManager.activeTrack.artist ?? "SYBAU"
                    color: Colors.color10
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Text {
                    id: songTitle
                    text: qsTr(MprisManager.activeTrack.title) ?? "SYBAU"
                    color: Colors.color11
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StyledButton {
                        icon: "\uf04a"
                        size: 48
                        iconRatio: 0.5
                        backgroundColor: Colors.background
                        hoverColor: Colors.color15
                        iconColor: Colors.color10
                        onClicked: MprisManager.togglePlaying()
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
                        onClicked: MprisManager.togglePlaying()
                    }
                    Spacer {}

                    Repeater {

                        model: {
                            return MprisManager.availablePlayers;
                        }

                        delegate: ClippingRectangle {

                            width: Math.round(isPortrait ? parent.height : parent.height)
                            height: Math.round(isPortrait ? parent.height : parent.height)
                            radius: Math.round(isPortrait ? parent.height / 2 : parent.height / 2)

                            color: "green"

                            Image {
                                source: modelData.trackArtUrl
                                fillMode: Image.PreserveAspectCrop
                                cache: true
                                smooth: true
                                mipmap: true
                                width: Math.round(parent.width)
                                height: Math.round(parent.height)
                                sourceSize.width: width
                                sourceSize.height: height
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: MprisManager.trackedPlayer = modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
