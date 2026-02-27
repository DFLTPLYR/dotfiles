import QtQuick
import qs.config
import qs.utils

Item {
    id: root
    // reparent
    property bool usePanel: false
    property alias panelSource: panelItem.source
    property Spacing border: Spacing {}
    property Spacing margin: Spacing {}
    default property alias content: contentItem.data

    property alias borderRadius: contentItem.radius
    property alias borderWidth: contentItem.border.width
    property alias borderColor: contentItem.border.color

    // rectangle properties
    property alias color: contentItem.color

    Rectangle {
        id: contentItem

        anchors {
            fill: parent
            topMargin: root.usePanel ? Math.round(root.border.top) : root.margin.top
            bottomMargin: root.usePanel ? Math.round(root.border.bottom) : root.margin.bottom
            leftMargin: root.usePanel ? Math.round(root.border.left) : root.margin.left
            rightMargin: root.usePanel ? Math.round(root.border.right) : root.margin.right
        }

        color: "transparent"
        border.color: "transparent"
        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }

    BorderImage {
        id: panelItem
        visible: root.usePanel
        anchors {
            fill: parent
        }
        clip: true
        border {
            left: root.border.left
            top: root.border.top
            right: root.border.right
            bottom: root.border.bottom
        }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }

    Rectangle {
        visible: root.usePanel
        color: Scripts.setOpacity(Colors.color.background, 1)
        anchors {
            fill: panelItem
            topMargin: root.border.top / 2
            bottomMargin: root.border.bottom / 2
            leftMargin: root.border.left / 2
            rightMargin: root.border.right / 2
        }
        z: -1
    }
}
