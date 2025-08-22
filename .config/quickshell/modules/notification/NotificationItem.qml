import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Quickshell

import qs.utils
import qs.services

Rectangle {
    required property var modelData

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
            id: wrapper
            property var iconPath: modelData.image || Quickshell.iconPath(modelData.appIcon, true)
            visible: !!iconPath

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.height
            Layout.fillHeight: true

            color: "transparent"

            Image {
                id: image
                anchors.fill: parent
                source: wrapper.iconPath
                fillMode: Image.PreserveAspectCrop
                smooth: true
                visible: false
            }

            Rectangle {
                id: masking
                anchors.fill: parent
                radius: width / 2
                clip: true
            }

            OpacityMask {
                anchors.fill: parent
                source: image
                maskSource: masking
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
