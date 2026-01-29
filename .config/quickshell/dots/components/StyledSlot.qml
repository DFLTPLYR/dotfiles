import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: slotRoot
    color: "transparent"
    border.color: childHandler.containsDrag ? Colors.color.primary : "transparent"

    Behavior on border.color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }

    default property alias content: childHandler.data
    property int alignment: Config.navbar.side ? Qt.AlignTop | Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignHCenter

    DropArea {
        id: childHandler
        anchors.fill: parent
        onChildrenChanged: {
            const copy = children.slice();
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (slotLayoutLoader.item && child.hasOwnProperty("isSlotted")) {
                    child.parent = slotLayoutLoader.item.children[0];
                }
            }
        }
    }

    component RowSlot: RowLayout {
        id: rootRowSlot
        default property alias content: childrenHolder.children
        property int alignment: Qt.AlignRight | Qt.AlignHCenter
        Row {
            id: childrenHolder
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: rootRowSlot.alignment

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
                child.parent = childHandler;
            }
        }
    }

    component ColSlot: ColumnLayout {
        id: rootColSlot
        default property alias content: childrenHolder.children
        property int alignment: Qt.AlignBottom | Qt.AlignHCenter
        Column {
            id: childrenHolder
            Layout.fillWidth: true
            Layout.alignment: rootColSlot.alignment
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

                child.parent = childHandler;
            }
        }
    }

    Component {
        id: colSlot
        ColSlot {
            alignment: slotRoot.alignment
        }
    }

    Component {
        id: rowSlot
        RowSlot {
            alignment: slotRoot.alignment
        }
    }

    Loader {
        id: slotLayoutLoader
        sourceComponent: Config.navbar.side ? colSlot : rowSlot
        anchors.fill: parent
    }
}
