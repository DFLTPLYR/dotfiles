import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.utils
import qs.services

Rectangle {
    required property var modelData

    implicitWidth: parent.width
    height: 90
    color: Scripts.setOpacity(Colors.background, 0.7)
    border.color: Colors.color1
    radius: 12
    clip: true

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 25
        height: 80
        spacing: 10

        Rectangle {
            visible: !!modelData.image || !!modelData.appIcon
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            Layout.fillHeight: true
            color: "transparent"
            clip: true
            Image {
                id: image
                anchors.fill: parent
                source: modelData.image || modelData.appIcon
                fillMode: Image.PreserveAspectFit
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 5

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: modelData.appName
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: Colors.color12
                }

                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(modelData.time), "hh:mm AP")
                    color: Colors.color11
                }
            }

            Text {
                text: modelData.body
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Colors.color11
            }

            Text {
                text: modelData.summary
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Colors.color10
            }
        }
    }
}
