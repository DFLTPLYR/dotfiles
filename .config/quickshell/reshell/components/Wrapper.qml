import Quickshell

import QtQuick

import qs.core
import qs.types

Rectangle {
    id: container
    property var container
    property Property config: Property {}

    color: "transparent"

    signal drop(int mouseX, int mouseY)
    signal swap(int item1, int item2)
    signal remove(int idx)

    Drag.hotSpot: Qt.point(width / 2, height / 2)
    Drag.active: ma.drag.active

    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: ma
        enabled: Global.widget
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        propagateComposedEvents: true
        drag.target: container
        drag.axis: Drag.XAxis
        onReleased: mouse => {
            if (mouse.button === Qt.LeftButton) {
                container.Drag.drop();
                container.drop(mouseX, mouseY);
                parent.x = 0;
                parent.y = 0;
            } else {
                container.remove(config.position);
            }
        }
    }

    DropArea {
        z: 1
        enabled: Global.widget
        anchors.fill: parent
        onDropped: drop => {
            container.swap(config.position, drop.source.config.position);
        }
        onContainsDragChanged: {
            background.border.color = containsDrag ? Colors.color.tertiary : "transparent";
        }

        Rectangle {
            id: background
            anchors.fill: parent
            color: "transparent"
        }
    }
}
