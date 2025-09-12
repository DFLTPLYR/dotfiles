import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Quickshell

import qs.utils
import qs.services
import qs.assets

Rectangle {
    required property var modelData

    height: 90
    color: Scripts.setOpacity(ColorPalette.background, 0.7)
    border.color: ColorPalette.color1
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
                    color: ColorPalette.color12
                }

                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(modelData.time), "hh:mm AP")
                    color: ColorPalette.color11
                }
            }

            Text {
                text: modelData.body
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: ColorPalette.color11
            }

            Text {
                text: modelData.summary
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                color: ColorPalette.color10
            }
        }
    }
}
