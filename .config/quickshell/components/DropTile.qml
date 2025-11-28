import QtQuick
import QtQuick.Controls

DropArea {
    id: dragTarget

    property string colorKey
    property int row: 1
    property int column: 1
    property bool isHovered: false

    width: 64 * row
    height: 64 * column

    keys: [colorKey, row, column]

    Rectangle {
        id: dropRectangle

        anchors.fill: parent
        color: dragTarget.containsDrag || dragTarget.isHovered ? "grey" : dragTarget.colorKey
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            function clamp(val, min, max) {
                return Math.max(min, Math.min(max, val));
            }
            switch (mouse.button) {
            case Qt.LeftButton:
                if (mouse.modifiers & Qt.ShiftModifier) {
                    // Shift + LeftClick → increase column
                    dragTarget.column = clamp(dragTarget.column + 1, 1, grid.columns);
                } else if (mouse.modifiers & Qt.ControlModifier) {
                    // Ctrl + LeftClick → decrease column
                    dragTarget.column = clamp(dragTarget.column - 1, 1, grid.columns);
                }
                break;
            case Qt.RightButton:
                if (mouse.modifiers & Qt.ShiftModifier) {
                    // Shift + RightClick → increase row
                    dragTarget.row = clamp(dragTarget.row + 1, 1, grid.rows);
                } else if (mouse.modifiers & Qt.ControlModifier) {
                    // Ctrl + RightClick → decrease row
                    dragTarget.row = clamp(dragTarget.row - 1, 1, grid.rows);
                }
                break;
            }
        }
    }
}
