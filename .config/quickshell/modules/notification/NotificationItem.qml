import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.utils
import qs.services

Rectangle {
    required property var modelData
    width: listview.width
    height: 80
    color: Scripts.setOpacity(Colors.background, 0.7)
    border.color: Colors.color1
    radius: 12

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Image {
            id: image
            source: modelData.image
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            Layout.fillHeight: true
            visible: modelData.image ?? false
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
                    color: Colors.color15
                }

                Text {
                    id: timeText
                    text: Qt.formatDateTime(new Date(modelData.time), "hh:mm AP")
                    color: Colors.color10
                }
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

    MouseArea {
        id: itemArea
        anchors.fill: parent
        onClicked: {
            NotificationService.timeoutNotification(modelData.notificationId);
        }
    }
}
