import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.components

ListView {
    id: container
    width: Global.general.notification.width
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
}
