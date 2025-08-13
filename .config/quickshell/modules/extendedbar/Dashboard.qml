import QtQuick
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

        GridLayout {
            anchors.centerIn: parent
            width: parent.width - 10
            height: parent.height - 10
            columnSpacing: 8
            rowSpacing: 8
            columns: Math.max(1, Math.floor(width / 100))

            // Rectangle {
            //     id: outerRect
            //     radius: 10
            //     Layout.fillWidth: true
            //     Layout.fillHeight: true
            //     color: "transparent"

            //     ColumnLayout {
            //         anchors.fill: parent
            //         anchors.margins: 10
            //         spacing: 8

            //         Text {
            //             id: name
            //             text: qsTr("Swap")
            //             color: Colors.color15
            //         }

            //         ColumnLayout {
            //             Layout.fillWidth: true
            //             Layout.fillHeight: true

            //             Text {
            //                 Layout.fillWidth: true
            //                 text: "Free"
            //                 color: "green"
            //                 horizontalAlignment: Text.AlignLeft
            //             }
            //             Rectangle {
            //                 Layout.fillWidth: true
            //                 height: 2
            //                 radius: 10
            //                 color: Colors.color10
            //             }
            //         }

            //         ColumnLayout {
            //             Layout.fillWidth: true
            //             Layout.fillHeight: true

            //             Text {
            //                 Layout.fillWidth: true
            //                 text: (SystemResource.memoryUsedPercentage * 100).toFixed(0)
            //                 color: "green"
            //                 horizontalAlignment: Text.AlignLeft
            //             }
            //             Rectangle {
            //                 Layout.fillWidth: true
            //                 height: 2
            //                 radius: 10
            //                 color: Colors.color10

            //                 Rectangle {
            //                     width: parent.width / (SystemResource.memoryUsedPercentage * 100).toFixed(0)
            //                     height: 2
            //                     radius: 10
            //                     color: Colors.color10
            //                 }
            //             }
            //         }
            //     }
            // }

            Rectangle {
                radius: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                function formatGB(value) {
                    return (value / (1024 * 1024)).toFixed(2) + " GB";
                }

                ColumnLayout {
                    anchors.centerIn: parent

                    Text {
                        font.family: FontAssets.fontAwesomeRegular
                        text: "\uf0ec"
                        font.pixelSize: 24
                        color: Colors.color14
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        color: Colors.color14
                        text: (SystemResource.swapUsedPercentage * 100).toFixed(1) + "%"
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4

                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 10
                    color: Colors.color14
                    text: parent.formatGB(SystemResource.swapUsed) + " / " + parent.formatGB(SystemResource.swapTotal)
                }

                Gauge {
                    value: SystemResource.swapUsedPercentage * 100
                    backgroundColor: Colors.color2
                    foregroundColor: Colors.color15
                    smoothRepaint: parentGrid.visible
                }
            }

            Rectangle {
                radius: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                function formatGB(value) {
                    return (value / (1024 * 1024)).toFixed(2) + " GB";
                }

                ColumnLayout {
                    anchors.centerIn: parent

                    Text {
                        font.family: FontAssets.fontAwesomeRegular
                        text: "\uf2d1"
                        font.pixelSize: 24
                        color: Colors.color14
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        color: Colors.color14
                        text: (SystemResource.memoryUsedPercentage * 100).toFixed(1) + "%"
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4

                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 10
                    color: Colors.color14
                    text: parent.formatGB(SystemResource.memoryUsed) + " / " + parent.formatGB(SystemResource.memoryTotal)
                }

                Gauge {
                    value: SystemResource.memoryUsedPercentage * 100
                    backgroundColor: Colors.color2
                    foregroundColor: Colors.color15
                    smoothRepaint: parentGrid.visible
                }
            }

            Rectangle {
                radius: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                function formatGB(value) {
                    return (value / (1024 * 1024)).toFixed(2) + " GB";
                }

                ColumnLayout {
                    anchors.centerIn: parent

                    Text {
                        font.family: FontAssets.fontAwesomeRegular
                        text: "\uf2db"
                        font.pixelSize: 24
                        color: Colors.color14
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        color: Colors.color14
                        text: (SystemResource.cpuUsage * 100).toFixed(1) + "%"
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4

                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 10
                    color: Colors.color14
                    text: 'Cpu Usage'
                }

                Gauge {
                    value: SystemResource.cpuUsage * 100
                    backgroundColor: Colors.color2
                    foregroundColor: Colors.color15
                    smoothRepaint: parentGrid.visible
                }
            }

            Rectangle {
                radius: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                ColumnLayout {
                    anchors.centerIn: parent

                    Text {
                        text: qsTr(`\uf093 ${SystemResource.netUpload}`)
                        color: Colors.color14
                    }

                    Text {
                        text: qsTr(`\uf019 ${SystemResource.netDownload}`)
                        color: Colors.color14
                    }
                }
            }
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
            anchors.fill: parent
            color: "transparent"

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
                    }

                    Canvas {
                        id: cavaBarCanvas
                        anchors.fill: parent
                        anchors.horizontalCenter: parent.horizontalCenter
                        property var values: parentGrid.values
                        visible: MprisManager.activePlayer.isPlaying
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            const barCount = values.length;
                            const centerX = width / 2;
                            const centerY = height / 2;
                            const radius = width / 3;
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
                                ctx.strokeStyle = Scripts.setOpacity(Colors.color10, 0.4);
                                ctx.lineWidth = 3;
                                ctx.stroke();
                            }
                        }

                        Connections {
                            target: parentGrid
                            onValuesChanged: cavaBarCanvas.requestPaint()
                        }
                    }
                }
            }

            Rectangle {
                id: albumDetails

                height: parent.height / 3
                color: "transparent"

                anchors.top: albumWrapper.bottom
                anchors.left: parent.left
                anchors.right: parent.right

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
                    iconColor: MprisManager.canGoPrevious ? Colors.color10 : Colors.color0
                    onClicked: MprisManager.previous()
                }

                StyledButton {
                    icon: MprisManager.isPlaying ? "\uf04c" : "\uf04b"
                    size: 48
                    iconRatio: 0.5
                    backgroundColor: Colors.background
                    hoverColor: Colors.color15
                    iconColor: MprisManager.canTogglePlaying ? Colors.color10 : Colors.color0
                    onClicked: MprisManager.togglePlaying()
                }

                StyledButton {
                    icon: "\uf04e"
                    size: 48
                    iconRatio: 0.5
                    backgroundColor: Colors.background
                    hoverColor: Colors.color15
                    iconColor: MprisManager.canGoNext ? Colors.color10 : Colors.color0
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
                                mipmap: true
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

                Rectangle {
                    color: 'transparent'
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    height: 20
                    Layout.columnSpan: 5

                    Text {
                        id: currentDate
                        text: qsTr(`${calendarWrapper.year} - ${calendarGrid.monthShort[calendarWrapper.month - 1]}`)
                        color: Colors.color15
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.centerIn: parent
                    }
                }

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
                        property bool selected: modelData === Time.date.getDate()
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
    property string selectedGif: ""

    property int count: 128
    property int noiseReduction: 60
    property string channels: "mono" // or stereo
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
    property var values: Array(count).fill(0) // 0 <= value <= 1

    function isSilent(vals, threshold) {
        let avg = 0;
        for (let i = 0; i < vals.length; i++)
            avg += vals[i];
        avg /= vals.length;
        for (let i = 0; i < vals.length; i++) {
            if (Math.abs(vals[i] - avg) > threshold)
                return false;
        }
        return true;
    }

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
