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

import qs.components
import qs.animations
import qs.services
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

    // Left Panel
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

                    AnimatedImage {
                        source: "../../assets/gifs/" + selectedGif
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        fillMode: AnimatedImage.PreserveAspectFit
                        cache: true
                        smooth: true
                    }
                }
            }
        }
    }

    // Middle Top Panel
    StackLayout {
        id: middleTopStack
        Layout.row: 0
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.rowSpan: 2
        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle {
            color: 'transparent'
            border.width: 1
            border.color: Colors.color1
            radius: 10

            opacity: middleTopStack.currentIndex === 0 ? 1 : 0

            Behavior on opacity {
                AnimatedNumber {}
            }

            MouseArea {
                anchors.fill: parent
                z: 1
                onClicked: {
                    middleTopStack.currentIndex++;
                }
            }
            SystemStats {}
        }

        Rectangle {
            color: 'transparent'
            border.width: 1
            border.color: Colors.color1
            radius: 10

            opacity: middleTopStack.currentIndex === 1 ? 1 : 0

            Behavior on opacity {
                AnimatedNumber {}
            }

            MouseArea {
                anchors.fill: parent
                z: 1
                onClicked: {
                    middleTopStack.currentIndex--;
                }
            }

            WeatherForecast {}
        }
    }

    // Middle Bottom
    RowLayout {
        Layout.row: 2
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.rowSpan: 3
        Layout.fillWidth: true
        Layout.fillHeight: true

        CalendarPanel {}

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
        }
    }

    // Right Panel
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

        MediaPanel {}
    }

    property var gifList: ["bongocat.gif", "Cat Spinning Sticker by pixel jeff.gif", "golshi.gif", "kurukuru.gif", "mambo.gif", "ogaricap.gif", "oiia.gif", "riceshower.gif", "tachyon2.gif", "tachyon3.gif", "tachyon.gif", "umamusumeprettyderby (1).gif", "umamusumeprettyderby.gif"]
    property string selectedGif: "bongocat.gif"

    Component.onCompleted: {
        selectedGif = gifList[Math.floor(Math.random() * gifList.length)];
    }
}
