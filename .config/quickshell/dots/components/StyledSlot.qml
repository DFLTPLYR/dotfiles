import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: slotRoot
    color: "transparent"

    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    default property alias content: childHandler.data
    property string position: "left"

    DropArea {
        id: childHandler
        anchors.fill: parent
        objectName: "handler"
        onContainsDragChanged: {
            slotRoot.border.color = containsDrag ? Colors.color.primary : "transparent";
        }
        onChildrenChanged: {
            Qt.callLater(() => {
                const copy = childHandler.children ? childHandler.children.slice() : [];
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
                for (let c = 0; c < childrenHolder.children.length; c++) {
                    const child = childrenHolder.children[c];
                    if (!child.hasOwnProperty("isSlotted"))
                        return;
                    child.implicitHeight = childrenHolder.height;
                    child.y = 0;
                    child.x = 0;
                }
            }
        }
        Component.onDestruction: {
            const copy = childrenHolder.children.slice();
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;

                const savedWidth = child.width;
                const savedHeight = child.height;

                child.parent = childHandler;
            }
        }
    }

    component ColSlot: ColumnLayout {
        id: rootColSlot
        default property alias content: childrenHolder.children
        Column {
            id: childrenHolder
            Layout.fillWidth: true
            Layout.alignment: {
                switch (slotRoot.position) {
                case "top" || "left":
                    return Qt.AlignTop;
                case "bottom" || "right":
                    return Qt.AlignBottom;
                case "center":
                    return Qt.AlignCenter;
                default:
                    return Qt.AlignTop;
                }
            }
            spacing: 4
            onChildrenChanged: {
                for (let c = 0; c < childrenHolder.children.length; c++) {
                    const child = childrenHolder.children[c];
                    if (!child.hasOwnProperty("isSlotted"))
                        return;

                    child.implicitWidth = childrenHolder.width;
                    child.y = 0;
                    child.x = 0;
                }
            }
        }
        Component.onDestruction: {
            const copy = childrenHolder.children.slice();
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;

                const savedWidth = child.width;
                const savedHeight = child.height;

                child.parent = childHandler;
            }
        }
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
        sourceComponent: Config.navbar.side ? colSlot : rowSlot
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
