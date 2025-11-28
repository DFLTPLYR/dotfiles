import QtQuick

DropArea {
    id: dragTarget

    property string colorKey
    property int row
    property int column

    width: 64
    height: 64
    keys: [colorKey, row, column]

    Rectangle {
        id: dropRectangle

        anchors.fill: parent
        color: dragTarget.containsDrag ? "grey" : dragTarget.colorKey
    }
}
