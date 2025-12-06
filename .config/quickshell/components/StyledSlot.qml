pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

Item {
    id: slotRoot
    default property alias content: childHandler.data
    property int alignment: Config.navbar.side ? Qt.AlignTop | Qt.AlignHCenter : Qt.AlignLeft | Qt.AlignHCenter

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
            Component.onDestruction: {
                console.log("RowSlot destroyed", children);
            }
        }
        Component.onDestruction: {
            const arr = childrenHolder.children.slice();
            Qt.callLater(() => {
                for (let c of arr)
                    c.parent = slotRoot.childHandler;
            });
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
        }
        Component.onDestruction: {
            const arr = childrenHolder.children.slice();
            Qt.callLater(() => {
                for (let c of arr)
                    c.parent = slotRoot.childHandler;
            });
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
        onLoaded: slotRoot.reparentChildren()
    }

    function reparentChildren() {
        const layoutItem = slotLayoutLoader.item;
        if (!layoutItem)
            return;
        const reparent = layoutItem.children[0];
        const arrayCopy = childHandler.children.slice();
        for (let c of arrayCopy) {
            if (c.parent !== reparent) {
                c.parent = reparent;
            }
        }
    }

    Connections {
        target: Config.navbar
        function onPositionChanged() {
            const oldLayout = slotLayoutLoader.item;
            if (!oldLayout)
                return;
            const oldContainer = oldLayout.children[0];
            if (!oldContainer)
                return;
            const childrenToMove = oldContainer.children.slice();

            for (let c of childrenToMove) {
                c.parent = childHandler;
            }

            slotLayoutLoader.sourceComponent = Config.navbar.side ? colSlot : rowSlot;
            slotLayoutLoader.active = true;
        }
    }

    Component.onCompleted: {
        slotLayoutLoader.sourceComponent = Config.navbar.side ? colSlot : rowSlot;
        slotLayoutLoader.active = true;
        slotRoot.reparentChildren();
    }
}
