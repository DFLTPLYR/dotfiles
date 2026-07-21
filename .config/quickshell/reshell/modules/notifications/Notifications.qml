pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

import qs.core

ListView {
    id: container
    property var config: Components.config.notification

    width: container.config.width
    height: parent.height
    verticalLayoutDirection: Components.config.notification.reverse ? ListView.BottomToTop : ListView.TopToBottom
    spacing: 2

    x: {
        switch (Components.config.notification.position) {
        case "left":
            return 0;
        case "middle":
            return (parent.width / 2) - (width / 2);
        case "right":
            return parent.width - width;
        default:
            return parent.width - width;
        }
    }

    visible: Compositor.focusedMonitor === screen.name
    opacity: Compositor.focusedMonitor === screen.name ? 1 : 0

    model: ScriptModel {
        values: [...Notifications.popupList]
    }

    delegate: NotificationItem {
        readonly property var style: container.config.style
        width: container.config.width
        height: container.config.height

        // Notification Bg
        bg {
            color: style.color

            bottomRightRadius: style.background.rounding.bottomRight
            bottomLeftRadius: style.background.rounding.bottomLeft
            topRightRadius: style.background.rounding.topRight
            topLeftRadius: style.background.rounding.topLeft
        }
    }

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
