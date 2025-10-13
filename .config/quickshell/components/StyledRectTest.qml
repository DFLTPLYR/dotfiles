import QtQuick
import qs.assets
import qs.utils

Item {
    default property alias content: childContainer.data
    property alias childContainerHeight: childContainer.height
    property real childContainerWidth: width

    layer.enabled: true
    width: parent.width
    implicitHeight: childContainer.height + 10

    anchors {
        topMargin: 2
        leftMargin: 5
        rightMargin: 5
        left: parent.left
        right: parent.right
        top: parent.top
    }

    Rectangle {
        width: childContainer.width + 10
        height: 50
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
        height: 50
        border.width: 1
        border.color: Scripts.setOpacity(ColorPalette.color10, 0.6)

        Binding {
            target: childContainer
            property: "width"
            value: childContainerWidth - 10
        }

    }

}
