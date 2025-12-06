import QtQuick
import QtQuick.Layouts

Item {
    id: slotRoot
    default property alias content: contentHolder.children

    QtObject {
        id: contentHolder
        property list<Item> children
    }

    Item {
        id: childHandler
        anchors.fill: parent
        visible: false
        Rectangle {
            height: parent.width
            width: parent.width
            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
        }
    }

    component RowSlot: RowLayout {
        anchors.fill: parent
        Row {
            Layout.fillHeight: true
            spacing: 4
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
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
    }

    Loader {
        id: slotLayoutLoader
        anchors.fill: parent
        sourceComponent: ColSlot {
            alignment: Qt.AlignCenter
        }
        onLoaded: slotRoot.reparentChildren()
    }

    function reparentChildren() {
        const layoutItem = slotLayoutLoader.item;
        if (!layoutItem)
            return;
        for (let c of contentHolder.children) {
            if (c.parent !== layoutItem.data[0]) {
                c.parent = layoutItem;
                console.log(layoutItem.data[0].children);
            }
        }
    }
}
