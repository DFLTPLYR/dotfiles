import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components
import qs.assets
import qs.utils
import qs

GridLayout {
    anchors.centerIn: parent
    width: parent.width - 10
    height: parent.height - 10
    columnSpacing: 8
    rowSpacing: 8
    columns: Math.max(1, Math.floor(width / 100))

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
