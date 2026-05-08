import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core

StyledPane {
    default property alias ma: notifMouseArea
    required property var modelData
    clip: true

    Rectangle {
        id: progressOutline
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 2
        color: Colors.color.primary

        NumberAnimation on width {
            from: 0
            to: parent ? parent.width : 0
            duration: Global.general.notification.duration
            running: true
        }
    }

    MouseArea {
        id: notifMouseArea
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAxis
        drag.minimumX: -width
        drag.maximumX: 0
        drag.threshold: 0

        onClicked: {
            Notifications.discardNotification(modelData.notificationId);
        }
        onReleased: {
            if (parent.x < -30) {
                Notifications.discardNotification(modelData.notificationId);
            } else {
                parent.x = 0;
            }
        }
    }

    Row {
        id: contentRow
        property bool hasImage: Quickshell.iconPath(modelData.appIcon, true) || modelData.image
        anchors.fill: parent

        Item {
            id: imageContainer
            height: contentRow.hasImage ? parent.height : 0
            width: contentRow.hasImage ? parent.height : 0

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: Quickshell.iconPath(modelData.appIcon, true) || modelData.image
            }
        }

        // Content
        ColumnLayout {
            anchors.left: imageContainer.right
            height: parent.height
            width: parent.width - imageContainer.width

            spacing: 2

            Text {
                Layout.fillWidth: true
                text: modelData.appName
                font.bold: true
                font.pointSize: 12
                color: Colors.color.primary
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: modelData.summary
                font.pointSize: 10
                color: Colors.color.on_background
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: modelData.body
                font.pointSize: 9
                color: Colors.color.secondary
                elide: Text.ElideRight
            }
        }
    }
}
