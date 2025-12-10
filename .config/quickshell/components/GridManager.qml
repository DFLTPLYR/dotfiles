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
    signal draggableChanged(var item, var positions)

    default property alias data: layoutItemContainer.data

    onChildrenChanged: {
        for (let i = 0; i < root.children.length; i++) {
            const child = root.children[i];
            if (child.hasOwnProperty("reparent") && child.reparent) {
                Qt.callLater(() => layoutItemContainer.wrapChild(child));
            }
        }
    }

    Row {
        id: layoutItemContainer
        property var wrappedChildren: []
        property var withWrappers: []

        Layout.fillWidth: true
        Layout.preferredHeight: layoutItemContainer.implicitHeight

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
                height: child.height,
                originalWidth: child.width,
                originalHeight: child.height,
                subject: child
            });
            child.parent = dragWrapper;
            child.visible = false;
            child.x = 0;
            child.y = 0;
            // Track
            wrappedChildren.push(child);
            withWrappers.push(dragWrapper);
        }

        onChildrenChanged: {
            for (let i = 0; i < layoutItemContainer.data.length; i++) {
                let child = layoutItemContainer.data[i];
                if (child.reparent) {
                    Qt.callLater(() => wrapChild(child));
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

        property Item subject
        property var positions
        property int originalWidth
        property int originalHeight
        property int col: 1
        property int row: 1

        z: 2

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

        Rectangle {
            id: tile

            width: parent.width
            height: parent.height

            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.2)

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
                    dragger.width = dragger.originalWidth;
                    dragger.height = dragger.originalHeight;
                    dragger.parent = layoutItemContainer;
                    root.draggableChanged(dragger, null);
                    dragger.subject.visible = false;
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
                dragger.subject.visible = true;
                dragger.subject.x = 0;
                dragger.subject.y = 0;
                root.draggableChanged(dragger, positions);
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
    }
}
