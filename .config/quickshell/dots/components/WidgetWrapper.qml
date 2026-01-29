pragma ComponentBehavior: Bound

import QtQuick
import qs.config

Rectangle {
    color: "transparent"
    property bool freeSlot: children.length >= 2
    width: 64
    height: 64
    border.color: freeSlot ? Colors.color.primary : Colors.color.tertiary

    Behavior on border.color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }

    DropArea {
        id: dragHandler
        anchors.fill: parent
    }
    MouseArea {
        id: ma
        property Item origParent
        property bool isSlotted: false
        width: isSlotted ? parent.width : 32
        height: isSlotted ? parent.height : 32
        drag.target: tile

        onReleased: parent = tile.Drag.target !== null ? tile.Drag.target : origParent

        Rectangle {
            id: tile
            width: ma.width
            height: ma.height
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            Drag.active: ma.drag.active

            states: State {
                when: ma.drag.active
                AnchorChanges {
                    target: tile
                    anchors {
                        verticalCenter: undefined
                        horizontalCenter: undefined
                    }
                }
            }
        }
        Component.onCompleted: {
            origParent = parent;
        }
    }
}
