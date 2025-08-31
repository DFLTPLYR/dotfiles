import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property real radius: 10
    property var sourceItem: null

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Item {
        id: content
        anchors.fill: parent
    }

    focus: false

    Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: root.radius
        clip: true
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: sourceItem
        maskSource: maskRect
    }

    onSourceItemChanged: {
        if (!sourceItem)
            return;
        if (sourceItem.parent !== content)
            sourceItem.parent = content;
        try {
            sourceItem.anchors.fill = content;
        } catch (e) {}
        sourceItem.visible = true;
    }
}
