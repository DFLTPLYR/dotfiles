import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core

ListView {
    id: container
    width: 400
    height: panel.height

    spacing: 2

    x: (panel.width * 1) - width

    visible: Compositor.focusedMonitor === screen.name
    opacity: Compositor.focusedMonitor === screen.name ? 1 : 0

    model: ScriptModel {
        values: [...Notifications.popupList]
    }

    delegate: NotificationItem {}

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InSine
        }
    }

    remove: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 250
        }
        NumberAnimation {
            property: "x"
            to: -200
            duration: 250
        }
    }

    add: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 250
        }
        NumberAnimation {
            property: "x"
            from: 200
            to: 0
            duration: 250
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: 250
        }
    }

    component NotificationItem: Rectangle {
        required property var modelData
        width: container.width
        height: 80
        color: Colors.setOpacity(Colors.color.background, 0.5)

        MouseArea {
            anchors.fill: parent
            drag.target: parent
            drag.axis: Drag.XAxis
            drag.minimumX: -width
            drag.maximumX: 0
            drag.threshold: 0

            onReleased: {
                if (parent.x < -30) {
                    Notifications.discardNotification(modelData.notificationId);
                } else {
                    parent.x = 0;
                }
            }
        }

        RowLayout {
            anchors {
                fill: parent
                margins: 2
            }
            // icon
            Image {
                id: notificationIcon
                visible: modelData.appIcon || modelData.image
                Layout.fillHeight: true
                Layout.preferredWidth: height
                Layout.margins: 2
                fillMode: Image.PreserveAspectCrop
                source: Qt.resolvedUrl(modelData.image || modelData.appIcon)
            }

            // content
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 2
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
}
