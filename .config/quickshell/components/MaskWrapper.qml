import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property real radius: 10
    property var sourceItem: null

    implicitHeight: sourceItem.height
    implicitWidth: sourceItem.width
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
}
