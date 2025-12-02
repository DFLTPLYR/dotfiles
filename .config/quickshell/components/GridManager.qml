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

    default property alias data: layoutItemContainer.data

    Row {
        id: layoutItemContainer
        property var wrappedChildren: []
        property var withWrappers: []

        Layout.fillWidth: true
        Layout.preferredHeight: 50

        Component {
            id: draggableWrapperComponent
            DraggableArea {}
        }

        function wrapChild(child) {
            // Skip if already wrapped
            if (wrappedChildren.indexOf(child) !== -1)
                return;

            // Create wrapper
            let dragWrapper = draggableWrapperComponent.createObject(layoutItemContainer, {
                width: child.width,
                height: child.height
            });

            if ("parent" in child) {
                child.parent = dragWrapper;
            } else {
                console.warn("Cannot reparent child:", child);
            }

            // Track
            wrappedChildren.push(child);
            withWrappers.push(dragWrapper);
        }

        onChildrenChanged: {
            console.log("Children changed, wrapping new children.");
            for (let i = 0; i < layoutItemContainer.data.length; i++) {
                let child = layoutItemContainer.data[i];
                if (child.reparent) {
                    Qt.callLater(() => wrapChild(child));  // <- defer creation
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
        property var positions
        property int col: 1
        property int row: 1

        width: 50 * row
        height: 50 * col

        z: 2

        onParentChanged: {
            if (parent === overlay) {
                console.log("Resetting draggable");
            }
        }

        Connections {
            target: gridCellsContainer
            function onColumnsChanged() {
                if (dragger.parent === overlay)
                    dragger.width = gridCellsContainer.width / gridCellsContainer.columns * dragger.col;
            }
            function onRowsChanged() {
                if (dragger.parent === overlay)
                    dragger.height = gridCellsContainer.height / gridCellsContainer.rows * dragger.row;
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

        Rectangle {
            id: tile

            width: parent.width
            height: parent.height

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.8)

            Drag.active: mouseArea.drag.active

            Drag.hotSpot.x: parent.width / 4
            Drag.hotSpot.y: parent.height / 4

            states: State {
                when: mouseArea.drag.active
                AnchorChanges {
                    target: tile
                    anchors {
                        verticalCenter: undefined
                        horizontalCenter: undefined
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag.target: tile

            drag.onActiveChanged: {
                if (drag.active) {
                    parent.width = width * 0.9;
                    parent.height = height * 0.9;
                }
            }

            onReleased: {
                // Get overlaps
                let overlaps = gridCellsContainer.updateCollision(tile);
                if (overlaps.length === 0) {
                    dragger.x = 0;
                    dragger.y = 0;
                    dragger.width = 50 * dragger.col;
                    dragger.height = 50 * dragger.row;
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

                dragger.parent = overlay;

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

                dragger.width = (dragger.col * cellWidth) * 0.9;
                dragger.height = (dragger.row * cellHeight) * 0.9;
            }
        }
    }
}
