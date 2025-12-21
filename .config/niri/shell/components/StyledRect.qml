import QtQuick

Item {
    id: root
    // reparent
    default property alias content: contentItem.data

    // rectangle properties
    property bool fill: false
    property alias color: contentItem.color
    property alias leftMargin: contentItem.anchors.leftMargin
    property alias rightMargin: contentItem.anchors.rightMargin
    property alias topMargin: contentItem.anchors.topMargin
    property alias bottomMargin: contentItem.anchors.bottomMargin

    Rectangle {
        id: contentItem
        anchors {
            fill: root.fill ? parent : undefined
        }
    }
}
