import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Rectangle {
    id: slotRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    DropArea {
        id: dragArea
        z: 1000
        anchors.fill: parent
    }
    default property alias content: childHandler.data
    property int alignment: Navbar.config.side ? Qt.AlignTop | Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignHCenter
    property bool debug: false

    onChildrenChanged: {
        const copy = children.slice();
        for (let i = 0; i < copy.length; i++) {
            const child = copy[i];
            if (slotLayoutLoader.item && child.hasOwnProperty("isSlotted")) {
                child.parent = slotLayoutLoader.item.children[0];
            }
        }
    }

    Item {
        id: childHandler
        anchors.fill: parent
        visible: false
    }

    component RowSlot: RowLayout {
        id: rootRowSlot
        default property alias content: childrenHolder.children
        property int alignment: Qt.AlignRight | Qt.AlignHCenter
        Row {
            id: childrenHolder
            Layout.fillHeight: true
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
                    child.isSlotted = true;
                }
            }
        }

        Component.onDestruction: {
            const copy = childrenHolder.children.slice();
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;

                child.isSlotted = false;
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
                    child.isSlotted = true;
                }
            }
        }

        Component.onDestruction: {
            const copy = childrenHolder.children.slice();
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                child.isSlotted = false;
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
        anchors.fill: parent
        sourceComponent: Navbar.config.side ? colSlot : rowSlot
        onLoaded: {
            const copy = childHandler.children.slice();
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                child.parent = item.children[0];
            }
            const copyparent = slotRoot.children.slice();
            for (let i = 0; i < copyparent.length; i++) {
                const child = copyparent[i];
                if (child.hasOwnProperty("module") && item) {
                    child.parent = slotLayoutLoader.item.children[0];
                }
            }
        }
    }
}
