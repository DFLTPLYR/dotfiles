import QtQuick
import QtQuick.Layouts
import qs.core

GridView {
    id: paletteGrid
    signal setColor(color color)
    interactive: false
    Layout.fillWidth: true
    Layout.preferredHeight: paletteGrid.contentHeight
    cellWidth: paletteGrid.width / 4
    cellHeight: cellWidth
    model: [...Colors.palettes]
    delegate: Rectangle {
        width: paletteGrid.cellWidth
        height: paletteGrid.cellHeight
        color: Colors.palette[modelData]
        MouseArea {
            anchors.fill: parent
            onClicked: {
                colorGrid.setColor(parent.color);
            }
        }
    }
}
