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

    delegate: Item {
        required property var modelData
        width: container.width
        height: 80
        clip: true

        RowLayout {
            anchors.fill: parent

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
                    color: "white"
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.summary
                    font.pointSize: 10
                    color: "white"
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.body
                    font.pointSize: 9
                    color: "lightgray"
                    elide: Text.ElideRight
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
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

    remove: Transition {
        id: removeTransition
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 250
        }
        NumberAnimation {
            property: "x"
            to: 200
            duration: 250
        }

        onRunningChanged: {
            if (!running && removeTransition.targetItem) {
                let notificationId = removeTransition.targetItem.notificationId;
                Notification.discardNotification(notificationId);
            }
        }
    }

    displaced: Transition {
        NumberAnimation {
            properties: "x,y"
            duration: 250
        }
    }
}
