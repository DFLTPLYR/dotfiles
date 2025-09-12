import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell

import qs.assets
import qs.utils

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 10
    color: "transparent"

    clip: true

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        model: NotificationService.appNameList
        delegate: NotificationGroup {
            required property var modelData
            group: modelData
            notifications: NotificationService.groupsByAppName[modelData].notifications
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
                to: -200
                duration: 250
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: 250
            }
        }

        Connections {
            target: NotificationService
            function onGroupsByAppNameChanged() {
                console.log(NotificationService.groupsByAppName);
            }
        }
    }
}
