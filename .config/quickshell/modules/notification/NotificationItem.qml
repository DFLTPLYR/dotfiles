import QtQuick

import Quickshell
import Quickshell.Widgets

import qs.utils
import qs.services

ClippingRectangle {
    width: parent.width
    height: 60
    color: "transparent"
    radius: 8
    border.color: Colors.color1
    border.width: 1

    Row {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 8

        Image {
            id: name
            width: parent.height
            height: width
            source: modelData.image
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
