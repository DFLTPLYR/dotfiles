import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.core

StyledPane {
    id: notif
    default property alias ma: notifMouseArea
    required property var modelData
    style: Components.config.notification.style
    clip: true

    function runAnim() {
        progressOutline.width = 0;
        anim.restart();
    }

    Rectangle {
        id: progressOutline

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 2
        color: Colors.theme.primary

        NumberAnimation on width {
            id: anim
            from: 0
            to: notif.width
            duration: Components.config.notification.duration
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
            Notifications.discardNotification(notif.modelData.notificationId);
        }
        onReleased: {
            if (parent.x < -30)
                Notifications.discardNotification(notif.modelData.notificationId);
            else
                parent.x = 0;
        }
    }

    Row {
        id: contentRow

        property bool hasImage: Quickshell.iconPath(notif.modelData.appIcon, true) || notif.modelData.image

        anchors.fill: parent

        Item {
            id: imageContainer

            height: contentRow.hasImage ? parent.height : 0
            width: contentRow.hasImage ? parent.height : 0

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                source: Quickshell.iconPath(notif.modelData.appIcon, true) || notif.modelData.image
            }
        }

        // Content
        ColumnLayout {
            height: parent.height
            width: parent.width - imageContainer.width
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: notif.modelData.appName
                font.bold: true
                font.pointSize: 12
                color: Colors.theme.primary
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: notif.modelData.summary
                font.pointSize: 10
                color: Colors.theme.on_surface
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: notif.modelData.body
                font.pointSize: 9
                color: Colors.theme.secondary
                elide: Text.ElideRight
            }
        }
    }
}
