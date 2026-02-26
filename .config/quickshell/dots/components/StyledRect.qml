import QtQuick
import qs.config

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
            topMargin: root.margin.top
            bottomMargin: root.margin.bottom
            leftMargin: root.margin.left
            rightMargin: root.margin.right
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
}
