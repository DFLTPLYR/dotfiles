pragma ComponentBehavior: Bound

import QtQuick
import qs.config

Rectangle {
    objectName: "handler"
    color: "transparent"
    property bool freeSlot: children.length >= 2
    default property alias content: widgetHandler.data
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
        objectName: "handler"
    }

    MouseArea {
        id: ma
        property Item origParent
        property bool isSlotted: false
        property real contentWidth: {
            let sum = 0;
            for (let i = 0; i < widgetHandler.children.length; i++) {
                sum += widgetHandler.children[i].width;
            }
            return sum;
        }

        width: isSlotted ? contentWidth : parent.width
        height: parent.height
        drag.target: tile

        onReleased: {
            parent = tile.Drag.target !== null ? tile.Drag.target : origParent;
        }

        onParentChanged: {
            if (parent.objectName === "handler") {
                return isSlotted = false;
            }
            return isSlotted = true;
        }

        Item {
            id: tile
            width: ma.width
            height: ma.height
            FontIcon {
                visible: !ma.isSlotted
                text: "plus"
                color: Colors.color.secondary
                font.pixelSize: parent.height * 0.8

                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Item {
                id: widgetHandler
                visible: ma.isSlotted
                anchors.fill: parent
            }

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
