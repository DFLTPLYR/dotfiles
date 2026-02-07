pragma ComponentBehavior: Bound

import QtQuick

import Quickshell

import qs.config

Rectangle {
    id: root
    objectName: "handler"
    color: "transparent"

    property string widgetName
    property string icon: "plus"
    property bool freeSlot: children.length >= 2

    property alias contentWidth: ma.contentWidth
    property alias contentHeight: ma.contentHeight

    signal reparent(string name, Item item)

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
        property string parentName: ""

        property real contentWidth
        property real contentHeight

        FontIcon {
            visible: !ma.isSlotted
            text: root.icon
            color: Colors.color.primary
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
        }

        width: {
            if (!parent)
                return 0;
            if (Config.navbar.side) {
                return parent.width;
            } else {
                return isSlotted ? contentWidth : parent.width;
            }
        }

        height: {
            if (!parent)
                return 0;
            if (Config.navbar.side) {
                return isSlotted ? contentHeight : parent.height;
            } else {
                return parent.height;
            }
        }

        drag.target: tile

        onReleased: {
            const dropArea = tile.Drag.target;
            const parentTarget = Config.navbar.widgets.findIndex(s => s.name === root.widgetName);
            if (dropArea) {
                if (dropArea.parent.objectName === "handler") {
                    parent = origParent;
                    parentName = "";
                    if (parentTarget === -1) {
                        Config.navbar.widgets.push({
                            name: root.widgetName,
                            layout: parentName
                        });
                    } else {
                        Config.navbar.widgets[parentTarget].layout = parentName;
                    }
                    return isSlotted = false;
                } else {
                    parent = dropArea;
                    parentName = dropArea.parent.objectName;
                    if (parentTarget === -1) {
                        Config.navbar.widgets.push({
                            name: root.widgetName,
                            layout: parentName
                        });
                    } else {
                        Config.navbar.widgets[parentTarget].layout = parentName;
                    }
                    return isSlotted = true;
                }
            } else {
                parent = origParent;
                parentName = "";
                if (parentTarget === -1) {
                    Config.navbar.widgets.push({
                        name: root.widgetName,
                        layout: parentName
                    });
                } else {
                    Config.navbar.widgets[parentTarget].layout = parentName;
                }
                return isSlotted = false;
            }
        }

        onParentChanged: {
            if (parent === null)
                reparent(parentName, ma);
        }

        Rectangle {
            id: tile
            clip: true
            visible: ma.isSlotted || ma.drag.active
            color: "transparent"
            border.color: "white"
            implicitWidth: parent.width
            implicitHeight: parent.height

            LazyLoader {
                id: loader
                active: true
                source: {
                    if (modelData.name !== "") {
                        return Quickshell.shellPath(`widgets/${root.widgetName}.qml`);
                    } else {
                        return "";
                    }
                }
                onLoadingChanged: {
                    if (!loading && item) {
                        item.parent = tile;
                        if (item.hasOwnProperty("enableActions")) {
                            item.enableActions = false;
                        }
                        item.isSlotted = true;
                        const parentTarget = Config.navbar.widgets.findIndex(s => s.name === root.widgetName);

                        if (parentTarget !== -1) {
                            const layout = Config.navbar.widgets[parentTarget].layout;
                            item.handler = layout;
                            ma.parentName = layout;
                            if (layout !== "")
                                ma.isSlotted = true;
                            return reparent(layout, ma);
                        }
                    }
                }
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
