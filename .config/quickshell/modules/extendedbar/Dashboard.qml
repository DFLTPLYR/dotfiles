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
import qs.utils
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
        color: "transparent"

        border.width: 1
        border.color: Colors.color1
        radius: 10

        Layout.row: 0
        Layout.column: 0
        Layout.rowSpan: 5
        Layout.minimumWidth: 80
        Layout.preferredWidth: Math.round(parent.width / 5)
        Layout.fillHeight: true
        Rectangle {
            anchors.fill: parent
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0 // no extra gap between rows

                // Weather top section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height / 3
                    spacing: -50
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        Layout.fillWidth: true
                        color: Colors.color10
                        text: "\uf0c2"
                        font.pixelSize: 50
                        font.family: FontAssets.fontAwesomeRegular
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        color: Colors.color10
                        text: WeatherFetcher.weatherInfo
                        font.pixelSize: 32
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Middle section (time)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: parent.height / 3
                    Text {
                        color: Colors.color10
                        text: Time.hoursPadded
                        font.pixelSize: 24
                    }
                    Rectangle {
                        color: Colors.color15
                        height: 1
                        Layout.preferredWidth: parent.width
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        color: Colors.color10
                        text: Time.minutesPadded
                        font.pixelSize: 24
                    }
                }

                // Bottom section
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height / 3
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    Text {
                        color: Colors.color10
                        text: 'Free space'
                        wrapMode: Text.Wrap
                        font.pixelSize: 20
                        font.family: FontAssets.fontAwesomeRegular
                    }
                }
            }
        }
    }

    // System data
    Rectangle {
        color: Scripts.hexToRgba(Colors.background, 0.8)

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
            color: Colors.color13
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
        color: "transparent"

        Layout.row: 2
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.rowSpan: 3
        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle {
            id: calendarWrapper
            anchors.fill: parent
            color: "transparent"

            property int year: Time.year
            property int month: Time.month

            function daysInMonth(y, m) {
                return new Date(y, m + 1, 0).getDate();
            }

            function firstDayOfMonth(y, m) {
                return new Date(y, m, 1).getDay();
            }

            GridLayout {
                id: calendarGrid
                anchors.fill: parent
                columns: 7
                rowSpacing: 4
                columnSpacing: 4
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                property var dayNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                Repeater {
                    model: calendarGrid.columns
                    delegate: Rectangle {
                        color: 'transparent'
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        height: 30

                        border.color: Colors.color1
                        radius: 4

                        Text {
                            anchors.centerIn: parent
                            text: calendarGrid.dayNames[index]
                            font.bold: true
                            color: Colors.color13
                        }
                    }
                }

                // Row 2+: Dates
                Repeater {
                    model: {
                        let totalDays = calendarWrapper.daysInMonth(calendarWrapper.year, calendarWrapper.month);
                        let startOffset = calendarWrapper.firstDayOfMonth(calendarWrapper.year, calendarWrapper.month);
                        let cells = [];
                        let totalCells = totalDays + startOffset;
                        for (let i = 0; i < totalCells; i++) {
                            if (i < startOffset) {
                                cells.push("");
                            } else {
                                cells.push(i - startOffset + 1);
                            }
                        }
                        return cells;
                    }

                    delegate: Rectangle {
                        property bool selected: modelData === Time.date.getDate()
                        color: selected ? Scripts.hexToRgba(Colors.color15, 0.2) : "transparent"
                        radius: 4
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        height: 40
                        border.color: Colors.color1
                        opacity: modelData != 0
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: selected ? Colors.color10 : Colors.color15
                        }
                    }
                }
            }
        }
    }
}
