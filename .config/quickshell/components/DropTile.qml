import QtQuick

DropArea {
    id: dragTarget

    property string colorKey

    width: 64
    height: 64
    keys: [colorKey]

    Rectangle {
        id: dropRectangle

        anchors.fill: parent
        color: dragTarget.containsDrag ? "grey" : dragTarget.colorKey
    }
}
