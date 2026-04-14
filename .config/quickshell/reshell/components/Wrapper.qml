import Quickshell

import QtQuick

import qs.core
import qs.types

Rectangle {
    id: wrapper
    property var container
    property var containerConfig

    property Property config: Property {}

    color: "transparent"

    signal drop(int mouseX, int mouseY)
    signal swap(int item1, int item2)
    signal remove(int idx)

    function setWidth(data) {
        if (wrapper.containerConfig) {
            return wrapper.containerConfig.side ? wrapper.container.width : data;
        }
        return 0;
    }

    function setHeight(data) {
        if (wrapper.containerConfig) {
            return !wrapper.containerConfig.side ? wrapper.container.height : data;
        }
        return 0;
    }

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
        drag.target: wrapper
        drag.axis: Drag.XAxis
        onReleased: mouse => {
            if (mouse.button === Qt.LeftButton) {
                wrapper.Drag.drop();
                wrapper.drop(mouseX, mouseY);
                parent.x = 0;
                parent.y = 0;
            } else {
                wrapper.remove(config.position);
            }
        }
    }

    DropArea {
        z: 1
        enabled: Global.widget
        anchors.fill: parent
        onDropped: drop => {
            wrappper.swap(config.position, drop.source.config.position);
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
