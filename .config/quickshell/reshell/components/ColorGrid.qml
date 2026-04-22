import QtQuick
import QtQuick.Layouts
import qs.core

GridView {
    id: colorGrid
    signal setColor(color color)
    interactive: false
    Layout.fillWidth: true
    Layout.preferredHeight: contentHeight
    cellWidth: colorGrid.width / 4
    cellHeight: cellWidth
    model: [...Colors.colors]
    delegate: Rectangle {
        width: colorGrid.cellWidth
        height: colorGrid.cellHeight
        color: Colors.color[modelData]

        MouseArea {
            anchors.fill: parent
            onClicked: {
                colorGrid.setColor(parent.color);
            }
        }
    }
}
