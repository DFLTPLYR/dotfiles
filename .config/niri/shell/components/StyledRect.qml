import QtQuick

Item {
    id: root
    // reparent
    default property alias content: contentItem.data

    property int borderWidth: 0
    property color borderColor: "transparent"

    // rectangle properties
    property bool fill: false
    property alias color: contentItem.color
    property alias leftMargin: contentItem.anchors.leftMargin
    property alias rightMargin: contentItem.anchors.rightMargin
    property alias topMargin: contentItem.anchors.topMargin
    property alias bottomMargin: contentItem.anchors.bottomMargin

    onBorderWidthChanged: {
        contentItem.border.width = root.borderWidth;
    }
    onBorderColorChanged: {
        contentItem.border.color = root.borderColor;
    }

    Rectangle {
        id: contentItem
        anchors {
            fill: root.fill ? parent : undefined
        }

        Behavior on color {
            ColorAnimation {
                duration: 250
                easing: Easing.InOutQuad
            }
        }
    }
}
