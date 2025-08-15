import QtQuick

import Quickshell
import qs.utils
import qs.services

Rectangle {
    width: parent.width
    height: 60
    color: "transparent"
    radius: 8
    border.color: Colors.color1
    border.width: 1

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        Image {
            id: name
            source: "file"
        }

        Column {
            Text {
                text: modelData.appName
                color: Colors.color12
                font.bold: true
            }
            Text {
                text: modelData.summary
                color: Colors.color10
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            NotificationService.discardNotification(modelData.notificationId);
        }
    }
}
