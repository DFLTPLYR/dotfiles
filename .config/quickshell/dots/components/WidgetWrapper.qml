pragma ComponentBehavior: Bound

import QtQuick
import qs.config

Rectangle {
    id: root
    objectName: "handler"
    color: "transparent"
    property string icon: "plus"
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
        property real contentHeight: {
            let sum = 0;
            for (let i = 0; i < widgetHandler.children.length; i++) {
                sum += widgetHandler.children[i].height;
            }
            return sum;
        }
        width: {
            if (Config.navbar.side) {
                return parent.width;
            } else {
                return isSlotted ? contentWidth : parent.width;
            }
        }
        height: {
            if (Config.navbar.side) {
                return isSlotted ? contentHeight : parent.height;
            } else {
                return parent.height;
            }
        }
        drag.target: tile

        onReleased: {
            parent = tile.Drag.target !== null ? tile.Drag.target : origParent;
        }

        onParentChanged: {
            if (!parent)
                return;
            if (parent.objectName === "handler") {
                return isSlotted = false;
            }
            return isSlotted = true;
        }

        Item {
            id: tile
            width: parent.width
            height: parent.height
            FontIcon {
                visible: !ma.isSlotted
                text: root.icon
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
