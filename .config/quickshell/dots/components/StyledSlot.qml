import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id: slotRoot
    Layout.fillWidth: true
    Layout.fillHeight: true

    default property alias content: childHandler.data
    property int alignment: Config.navbar.side ? Qt.AlignTop | Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignHCenter
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
    DropArea {
        anchors.fill: parent
    }
    Rectangle {
        id: childHandler
        anchors.fill: parent
        visible: true
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
                if (!child.hasOwnProperty("isSlotted"))
                    return;

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
        sourceComponent: Config.navbar.side ? colSlot : rowSlot
        onLoaded: {
            const copy = childHandler.children.slice();
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;
                child.parent = item.children[0];
            }
            const copyparent = slotRoot.children.slice();
            for (let i = 0; i < copyparent.length; i++) {
                const child = copyparent[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;
                if (child.hasOwnProperty("module") && item) {
                    child.parent = slotLayoutLoader.item.children[0];
                }
            }
        }
    }
}
