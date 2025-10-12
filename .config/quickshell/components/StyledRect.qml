import QtQuick
import qs.assets
import qs.utils

Item {
    default property alias content: childContainer.data

    layer.enabled: true
    width: parent.width
    implicitHeight: 40

    anchors {
        topMargin: 5
        leftMargin: 5
        rightMargin: 5
        left: parent.left
        right: parent.right
        top: parent.top
    }

    Rectangle {
        width: parent.width - 10
        height: 30
        radius: 2
        color: Scripts.setOpacity(ColorPalette.background, 0.8)
        border.width: 1
        border.color: Scripts.setOpacity(ColorPalette.color10, 0.4)
    }

    Rectangle {
        id: childContainer

        x: 5
        y: 5
        radius: 2
        color: Scripts.setOpacity(ColorPalette.background, 0.8)
        width: parent.width - 10
        height: 30
        border.width: 1
        border.color: Scripts.setOpacity(ColorPalette.color10, 0.6)
    }

}
