import QtQuick
import qs.config
import qs.utils

Item {
    id: root

    // reparent
    property bool usePanel: false
    property alias panelSource: panelItem.source
    property Spacing border
    property Spacing margin
    default property alias content: contentItem.data
    property alias borderRadius: contentItem.radius
    property alias borderWidth: contentItem.border.width
    property alias borderColor: contentItem.border.color
    // rectangle properties
    property alias color: contentItem.color

    Rectangle {
        id: contentItem

        z: root.usePanel ? -1 : 1
        color: "transparent"
        border.color: "transparent"

        anchors {
            fill: parent
            topMargin: root.usePanel ? Math.round(root.border.top) / 2 : root.margin.top
            bottomMargin: root.usePanel ? Math.round(root.border.bottom) / 2 : root.margin.bottom
            leftMargin: root.usePanel ? Math.round(root.border.left) / 2 : root.margin.left
            rightMargin: root.usePanel ? Math.round(root.border.right) / 2 : root.margin.right
        }

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
        clip: true
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch

        anchors {
            fill: parent
        }

        border {
            left: root.border.left
            top: root.border.top
            right: root.border.right
            bottom: root.border.bottom
        }

    }

    Rectangle {
        visible: root.usePanel
        color: Scripts.setOpacity(Colors.color.background, 1)
        z: -1

        anchors {
            fill: panelItem
            topMargin: root.border.top / 2
            bottomMargin: root.border.bottom / 2
            leftMargin: root.border.left / 2
            rightMargin: root.border.right / 2
        }

    }

    border: Spacing {
    }

    margin: Spacing {
    }

}
