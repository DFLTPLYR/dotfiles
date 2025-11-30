import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Io

import qs.utils
import qs.config

ColumnLayout {
    id: root
    property int cellColumns: 1
    property int cellRows: 1
    property int layoutAmmount: 1
    signal draggableChanged(var item, var positions)

    // draggables container
    Row {
        id: layoutItemContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        z: 10
        Item {
            width: 1
            height: 50
        }
        Repeater {
            id: layoutItemRepeater
            model: ScriptModel {
                values: {
                    return Array.from({
                        length: root.layoutAmmount
                    }, (_, i) => i);
                }
            }
            delegate: DraggableArea {
                id: dragItem
                parentItem: overlay

                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
                }
                Connections {
                    target: gridCellsContainer
                    function onColumnsChanged() {
                        if (dragItem.parent === parentItem)
                            dragItem.width = gridCellsContainer.width / gridCellsContainer.columns * dragItem.col;
                    }
                    function onRowsChanged() {
                        if (dragItem.parent === parentItem)
                            dragItem.height = gridCellsContainer.height / gridCellsContainer.rows * dragItem.row;
                    }
                }
            }
        }
    }

    // Grid preview
    Item {
        id: gridComponentContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 400

        //Bg color
        Rectangle {
            anchors.fill: parent
            color: Scripts.setOpacity(Color.background, 0.5)
        }

        Item {
            id: overlay
            anchors.fill: parent
        }

        Grid {
            id: gridCellsContainer
            anchors.fill: parent
            columns: Math.max(1, root.cellColumns)
            rows: Math.max(1, root.cellRows)

            function updateCollision(dragItem) {
                let overlaps = [];
                for (let i = 0; i < cellRepeater.count; i++) {
                    let cell = cellRepeater.itemAt(i);
                    if (!cell)
                        continue;

                    let a = Scripts.rectBounds(dragItem);
                    let b = Scripts.rectBounds(cell);

                    if (Scripts.intersects(a, b)) {
                        overlaps.push([Math.floor(i / columns), i % columns]);
                        cell.color = "#22ddff33";
                    } else {
                        cell.color = "transparent";
                    }
                }
                return overlaps;
            }

            Repeater {
                id: cellRepeater
                model: ScriptModel {
                    values: {
                        return Array.from({
                            length: gridCellsContainer.columns * gridCellsContainer.rows
                        }, (_, i) => i);
                    }
                }
                delegate: Rectangle {
                    width: gridCellsContainer.width / gridCellsContainer.columns
                    height: gridCellsContainer.height / gridCellsContainer.rows
                    color: "transparent"
                    border.color: "green"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData + 1
                    }
                }
            }
        }
    }

    // Draggable component
    component DraggableArea: Item {
        id: dragger
        property Item parentItem: parent
        property var positions
        property int col: 1
        property int row: 1

        width: 50 * row
        height: 50 * col

        z: 2

        onParentChanged: {
            if (parent === parentItem) {
                console.log("Resetting draggable");
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag.target: parent

            drag.onActiveChanged: {
                if (drag.active) {
                    parent.width = width * 0.9;
                    parent.height = height * 0.9;
                }
            }

            onReleased: {
                // Get overlaps
                let overlaps = gridCellsContainer.updateCollision(dragger);
                if (overlaps.length === 0) {
                    dragger.x = 0;
                    dragger.y = 0;
                    dragger.width = 50 * dragger.row;
                    dragger.height = 50 * dragger.col;
                    dragger.parent = layoutItemContainer;
                    root.draggableChanged(dragger, null);
                    return;
                }

                // Compute bounding cells
                let rows = overlaps.map(c => c[0]);
                let cols = overlaps.map(c => c[1]);
                let row = Math.min(...rows);
                let lastRow = Math.max(...rows);
                let rowspan = lastRow - row + 1;
                let col = Math.min(...cols);
                let lastCol = Math.max(...cols);
                let colspan = lastCol - col + 1;

                positions = {
                    row: row,
                    col: col,
                    rowspan: rowspan,
                    colspan: colspan
                };

                dragger.parent = dragger.parentItem;

                // Cell sizes
                let cellWidth = gridCellsContainer.width / gridCellsContainer.columns;
                let cellHeight = gridCellsContainer.height / gridCellsContainer.rows;

                // Snap to grid
                dragger.x = col * cellWidth;
                dragger.y = row * cellHeight;
                dragger.row = rowspan;
                dragger.col = colspan;
                dragger.width = colspan * cellWidth;
                dragger.height = rowspan * cellHeight;
                root.draggableChanged(dragger, positions);
            }
        }

        WheelHandler {
            id: wheelHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            onWheel: event => {
                if (!mouseArea.drag.active)
                    return;

                const isShift = event.modifiers & Qt.ShiftModifier;
                const isCtrl = event.modifiers & Qt.ControlModifier;
                const scrollup = event.angleDelta.y > 0;
                if (!isShift && !isCtrl)
                    return;
                if (isShift) {
                    if (scrollup)
                        dragger.col = Math.min(dragger.col + 1, gridCellsContainer.columns);
                    else
                        dragger.col = Math.max(dragger.col - 1, 1);
                }

                if (isCtrl) {
                    if (scrollup)
                        dragger.row = Math.min(dragger.row + 1, gridCellsContainer.rows);
                    else
                        dragger.row = Math.max(dragger.row - 1, 1);
                }

                let cellWidth = gridCellsContainer.width / gridCellsContainer.columns;
                let cellHeight = gridCellsContainer.height / gridCellsContainer.rows;

                dragger.width = dragger.col * cellWidth;
                dragger.height = dragger.row * cellHeight;
            }
        }
    }
}
