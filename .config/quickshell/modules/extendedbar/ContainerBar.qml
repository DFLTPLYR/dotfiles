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
        border.color: Assets.color1
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
                        color: Assets.color10
                        text: WeatherFetcher.currentCondition?.icon ?? ""
                        font.pixelSize: 50
                        font.family: FontAssets.fontMaterialOutlined
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        color: Assets.color10
                        text: WeatherFetcher.currentCondition?.feelslike ?? ""
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
                        color: Assets.color10
                        text: TimeService.hoursPadded
                        font.pixelSize: 24
                    }
                    Rectangle {
                        color: Assets.color15
                        height: 1
                        Layout.preferredWidth: parent.width
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        color: Assets.color10
                        text: TimeService.minutesPadded
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
            border.color: Assets.color1
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
            border.color: Assets.color1
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

        NotificationsPanel {}
    }

    // Right Panel
    Rectangle {
        color: "transparent"

        border.width: 1
        border.color: Assets.color1
        radius: 10

        Layout.row: 0
        Layout.column: 4
        Layout.rowSpan: 5
        Layout.minimumWidth: 80
        Layout.preferredWidth: Math.round(parent.width / 5)
        Layout.fillHeight: true

        MediaPanel {}
    }

    property var gifList: ["bongocat.gif", "ogaricap.gif", "tachyon3.gif", "umamusumeprettyderby.gif", "Cat Spinning Sticker by pixel jeff.gif", "oiia.gif", "tachyon4.gif", "uma-musume-rice-shower.gif", "golshi.gif", "riceshower.gif", "tachyon.gif", "kurukuru.gif", "seseren-umamusume.gif", "uma-musume-gold-ship.gif", "mambo.gif", "tachyon2.gif", "umamusumeprettyderby (1).gif"]
    property string selectedGif: "bongocat.gif"

    Component.onCompleted: {
        selectedGif = gifList[Math.floor(Math.random() * gifList.length)];
    }
}
