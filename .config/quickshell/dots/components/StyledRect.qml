import QtQuick

Item {
    id: root
    // reparent
    default property alias content: contentItem.data

    property int borderRadius: 0
    property int borderWidth: 0
    property color borderColor: "transparent"

    // rectangle properties
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

    onBorderRadiusChanged: {
        contentItem.radius = root.borderRadius;
    }

    Rectangle {
        id: contentItem
        anchors {
            fill: parent
        }

        Behavior on color {
            ColorAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }
    }
}
