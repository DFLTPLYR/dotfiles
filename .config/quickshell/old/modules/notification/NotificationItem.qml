import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Quickshell

import qs.config
import qs.utils
import qs.services
import qs.assets
import qs.components

StyledRect {
    required property var modelData

    childContainerHeight: 80

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 25

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
                id: maskee
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
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                source: maskee
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
                    font.family: FontProvider.fontSometypeItalic
                    text: modelData.appName
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: Color.color12
                }

                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(modelData.time), "hh:mm AP")
                    color: Color.color11
                }
            }

            Text {
                text: modelData.body
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Color.color11
            }

            Text {
                text: modelData.summary
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: Color.color10
            }
        }
    }
}
