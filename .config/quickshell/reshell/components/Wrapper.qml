import Quickshell

import QtQuick

import qs.core
import qs.types

Item {
    id: container
    property Property config: Property {}

    signal drop(int mouseX, int mouseY)
    signal swap(int item1, int item2)

    Drag.active: ma.drag.active

    MouseArea {
        id: ma
        enabled: Global.widget
        anchors.fill: parent
        propagateComposedEvents: true
        drag.target: container
        onReleased: {
            container.Drag.drop();
            container.drop(mouseX, mouseY);
        }
    }

    DropArea {
        z: 1
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
