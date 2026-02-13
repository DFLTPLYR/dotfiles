import QtQuick
import QtQuick.Layouts

import qs.config
import qs.utils

Rectangle {
    id: slotRoot
    color: "transparent"
    border.color: "transparent"
    signal slotDestroyed(var widgets)
    property list<Item> widgets: []

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    default property alias content: childHandler.data
    property string position: "left"

    onChildrenChanged: {
        Qt.callLater(() => {
            const copy = children ? children.slice() : [];
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (slotLayoutLoader && slotLayoutLoader.item && child.hasOwnProperty("isSlotted")) {
                    child.parent = slotLayoutLoader.item.children[0];
                }
            }
        });
    }

    DropArea {
        id: childHandler
        anchors.fill: parent
        objectName: "handler"
        onContainsDragChanged: {
            slotRoot.border.color = containsDrag ? Colors.color.primary : "transparent";
        }
        onChildrenChanged: {
            Qt.callLater(() => {
                const copy = (childHandler && childHandler.children) ? childHandler.children.slice() : [];
                for (let i = 0; i < copy.length; i++) {
                    const child = copy[i];
                    if (slotLayoutLoader.item && child.hasOwnProperty("isSlotted")) {
                        child.parent = slotLayoutLoader.item.children[0];
                    }
                }
            });
        }
    }

    component RowSlot: RowLayout {
        id: rootRowSlot
        default property alias content: childrenHolder.children

        Row {
            id: childrenHolder
            objectName: modelData.name
            Layout.fillHeight: true
            Layout.alignment: {
                switch (slotRoot.position) {
                case "left" || "top":
                    return Qt.AlignLeft;
                case "right" || "bottom":
                    return Qt.AlignRight;
                case "center":
                    return Qt.AlignCenter;
                default:
                    break;
                }
            }

            spacing: 4
            onChildrenChanged: {
                const widgets = childrenHolder.children.filter(c => c.isSlotted !== undefined);
                widgets.forEach((child, index) => {
                    child.implicitHeight = childrenHolder.height;
                    child.y = 0;
                    child.x = 0;
                    const widgetList = Navbar.config.widgets.filter(s => s.layout === modelData.name);
                    const currentChildren = children.filter(s => s.isSlotted);
                    const config = Navbar.config.widgets.find(w => w.name === child.origParent?.widgetName);
                    if (config && widgetList.length === currentChildren.length)
                        config.position = index;
                });
            }
        }

        Component.onDestruction: {
            const copy = childrenHolder.children.slice();
            slotRoot.widgets = [];
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;
                const savedWidth = child.width;
                const savedHeight = child.height;
                slotRoot.widgets.push(child);
                child.parent = childHandler;
            }
            slotRoot.slotDestroyed(slotRoot.widgets);
        }
    }

    component ColSlot: ColumnLayout {
        id: rootColSlot
        default property alias content: childrenHolder.children
        Column {
            id: childrenHolder
            objectName: modelData.name
            Layout.fillWidth: true
            Layout.alignment: {
                switch (slotRoot.position) {
                case "left":
                    return Qt.AlignTop;
                case "right":
                    return Qt.AlignBottom;
                case "center":
                    return Qt.AlignCenter;
                default:
                    return;
                }
            }
            spacing: 4
            onChildrenChanged: {
                const widgets = childrenHolder.children.filter(c => c.isSlotted !== undefined);
                widgets.forEach((child, index) => {
                    child.implicitHeight = childrenHolder.height;
                    child.y = 0;
                    child.x = 0;
                    const widgetList = Navbar.config.widgets.filter(s => s.layout === modelData.name);
                    const currentChildren = children.filter(s => s.isSlotted);
                    const config = Navbar.config.widgets.find(w => w.name === child.origParent?.widgetName);
                    if (config && widgetList.length === currentChildren.length)
                        config.position = index;
                });
            }
        }

        Component.onDestruction: {
            const copy = childrenHolder.children.slice();
            slotRoot.widgets = [];
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;
                const savedWidth = child.width;
                const savedHeight = child.height;
                slotRoot.widgets.push(child);
                child.parent = childHandler;
            }
            slotRoot.slotDestroyed(slotRoot.widgets);
        }
    }

    Component.onDestruction: {
        slotRoot.slotDestroyed(slotRoot.widgets);
    }

    Component {
        id: colSlot
        ColSlot {}
    }

    Component {
        id: rowSlot
        RowSlot {}
    }

    Loader {
        id: slotLayoutLoader
        sourceComponent: Navbar.config.side ? colSlot : rowSlot
        anchors.fill: parent
        onLoaded: {
            const copy = childHandler.children ? childHandler.children.slice() : [];
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (slotLayoutLoader.item && child.hasOwnProperty("isSlotted")) {
                    child.parent = slotLayoutLoader.item.children[0];
                }
            }
        }
    }
}
