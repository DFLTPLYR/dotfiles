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

    // System data
    Rectangle {
        color: 'transparent'

        border.width: 1
        border.color: Colors.color1
        radius: 10

        Layout.row: 0
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.rowSpan: 2
        Layout.fillWidth: true
        Layout.fillHeight: true

        SystemStats {}
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

        MediaPanel {}
    }

    // Calendar
    RowLayout {
        Layout.row: 2
        Layout.column: 1
        Layout.columnSpan: 3
        Layout.rowSpan: 3
        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle {
            id: calendarWrapper
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            property int year: Time.year
            property int month: Time.month

            property int currentYear: Time.year
            property int currentMonth: Time.month

            property bool isCurrentDate: currentYear === year && currentMonth === month

            function goToToday() {
                year = currentYear;
                month = currentMonth;
            }

            function incrementMonth() {
                if (calendarWrapper.month >= 12) {
                    calendarWrapper.month = 1;
                    calendarWrapper.year++;
                } else {
                    calendarWrapper.month++;
                }
            }

            function decrementMonth() {
                if (calendarWrapper.month <= 1) {
                    calendarWrapper.month = 12;
                    calendarWrapper.year--;
                } else {
                    calendarWrapper.month--;
                }
            }

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
                property var monthShort: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

                // Prev Button
                Rectangle {
                    color: 'transparent'
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    height: 20

                    border.color: prevBtnMA.containsMouse ? Colors.color12 : Colors.color1
                    radius: 4

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        id: prevBtn
                        text: '\uf0d9'
                        color: Colors.color15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: prevBtnMA
                        anchors.fill: parent
                        onClicked: calendarWrapper.decrementMonth()
                        z: 1
                    }
                }

                // Date Year Month
                Rectangle {
                    color: 'transparent'
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    height: 20
                    Layout.columnSpan: 5

                    Text {
                        id: currentDate
                        anchors.centerIn: parent
                        text: qsTr(`${calendarWrapper.year} - ${calendarGrid.monthShort[calendarWrapper.month - 1]}`)
                        color: Colors.color15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: calendarWrapper.goToToday()
                            z: 1
                        }
                    }
                }

                // Next Button
                Rectangle {
                    color: 'transparent'
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    height: 20

                    border.color: nextBtnMA.containsMouse ? Colors.color12 : Colors.color1
                    radius: 4
                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        id: nextBtn
                        text: '\uf0da'
                        color: Colors.color15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: nextBtnMA
                        anchors.fill: parent
                        onClicked: calendarWrapper.incrementMonth()
                        z: 1
                    }
                }

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
                            color: Colors.color11
                        }
                    }
                }

                Repeater {
                    model: {
                        let year = calendarWrapper.year;
                        let month = calendarWrapper.month - 1;
                        let totalDays = calendarWrapper.daysInMonth(year, month);
                        let startOffset = calendarWrapper.firstDayOfMonth(year, month);
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
                        property bool selected: {
                            return modelData === Time.date.getDate() && calendarWrapper.isCurrentDate;
                        }

                        color: selected ? Scripts.hexToRgba(Colors.color15, 0.2) : "transparent"
                        radius: 4

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        border.color: Colors.color1

                        Text {
                            anchors.centerIn: parent
                            text: modelData ? modelData : '\uf111'
                            font.pixelSize: modelData ? 12 : 6
                            color: modelData ? (selected ? Colors.color10 : Colors.color15) : Colors.color0
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
        }
    }

    property var gifList: ["bongocat.gif", "Cat Spinning Sticker by pixel jeff.gif", "golshi.gif", "kurukuru.gif", "mambo.gif", "ogaricap.gif", "oiia.gif", "riceshower.gif", "tachyon2.gif", "tachyon3.gif", "tachyon.gif", "umamusumeprettyderby (1).gif", "umamusumeprettyderby.gif"]
    property string selectedGif: "bongocat.gif"

    property int count: 256
    property int noiseReduction: 60
    property string channels: "stereo" // or stereo
    property string monoOption: "average" // or left or right
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

    Component.onCompleted: {
        selectedGif = gifList[Math.floor(Math.random() * gifList.length)];
    }
}
