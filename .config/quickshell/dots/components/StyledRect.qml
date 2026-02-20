import QtQuick

Item {
    id: root
    // reparent
    property bool usePanel: false
    property alias panelSource: panelItem.source
    default property alias content: contentItem.data

    property alias borderRadius: contentItem.radius
    property alias borderWidth: contentItem.border.width
    property alias borderColor: contentItem.border.color

    // rectangle properties
    property alias color: contentItem.color
    property alias leftMargin: contentItem.anchors.leftMargin
    property alias rightMargin: contentItem.anchors.rightMargin
    property alias topMargin: contentItem.anchors.topMargin
    property alias bottomMargin: contentItem.anchors.bottomMargin

    Rectangle {
        id: contentItem
        visible: !root.usePanel
        anchors {
            fill: parent
        }
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
        border {
            left: 10
            top: 10
            right: 10
            bottom: 10
        }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }
}
