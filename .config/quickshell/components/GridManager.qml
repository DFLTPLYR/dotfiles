import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.utils
import qs.config

ColumnLayout {
    id: root
    property int preferredHeight: 400
    property int preferredWidth: 400
    property int cellColumns: 1
    property int cellRows: 1
    signal draggableChanged(var item, var positions)

    default property alias data: layoutItemContainer.data

    onChildrenChanged: {
        for (let i = 0; i < root.children.length; i++) {
            const child = root.children[i];
            if (child.hasOwnProperty("reparent")) {
                Qt.callLater(() => layoutItemContainer.wrapChild(child));
            }
        }
    }

    Flow {
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
            child.reparent = true;
            const multiplier = Config.navbar.side ? child.row : child.column;

            let dragWrapper = draggableWrapperComponent.createObject(layoutItemContainer, {
                width: Config.navbar.side ? 50 : 50 * multiplier,
                height: Config.navbar.side ? 50 * multiplier : 50,
                subject: child
            });

            child.parent = dragWrapper;
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
        Layout.preferredWidth: root.preferredWidth
        Layout.preferredHeight: root.preferredHeight

        Rectangle {
            id: overlay
            anchors.fill: gridCellsContainer
            color: Scripts.setOpacity(Color.background, 0.5)
        }

        Grid {
            id: gridCellsContainer
            width: parent.width
            height: parent.height
            columns: Math.max(1, root.cellColumns)
            rows: Math.max(1, root.cellRows)

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
                    property bool hasItem: false
                    width: parent.width / parent.columns
                    height: parent.height / parent.rows
                    color: "transparent"
                    border.color: "green"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    function updateCollisionVisual(dragItem, reset = false) {
        const requiredCount = Config.navbar.side ? dragItem.parent.subject.row : dragItem.parent.subject.column;

        let overlaps = [];
        let highlightColor;
        let borderColor;

        for (let i = 0; i < cellRepeater.count; i++) {
            let cell = cellRepeater.itemAt(i);
            if (cell && !cell.hasItem) {
                cell.color = "transparent";
                cell.border.color = "green";
                cell.opacity = 1;
            }
        }
        if (reset)
            return;

        for (let i = 0; i < cellRepeater.count; i++) {
            let cell = cellRepeater.itemAt(i);
            if (!cell)
                continue;

            let a = Scripts.rectBounds(dragItem);
            let b = Scripts.rectBounds(cell);

            if (Scripts.intersects(a, b)) {
                overlaps.push(cell);
            }
        }

        if (overlaps.length < requiredCount) {
            highlightColor = Scripts.setOpacity("red", 0.2);
            borderColor = "red";
        } else {
            highlightColor = Scripts.setOpacity(Color.accent, 0.5);
            borderColor = Color.accent;
        }

        for (let cell of overlaps) {
            cell.color = highlightColor;
            cell.border.color = borderColor;
        }
    }

    function updateCollision(dragItem) {
        let overlaps = [];
        for (let i = 0; i < cellRepeater.count; i++) {
            let cell = cellRepeater.itemAt(i);
            if (!cell)
                continue;

            let a = Scripts.rectBounds(dragItem);
            let b = Scripts.rectBounds(cell);

            if (Scripts.intersects(a, b)) {
                overlaps.push([Math.floor(i / gridCellsContainer.columns), i % gridCellsContainer.columns]);
                cell.opacity = 0;
                cell.hasItem = true;
            }
        }

        return overlaps;
    }

    function clearOccupiedCells(positions) {
        if (!positions)
            return;
        for (let r = positions.row; r < positions.row + positions.rowspan; r++) {
            for (let c = positions.col; c < positions.col + positions.colspan; c++) {
                let idx = r * gridCellsContainer.columns + c;
                let cell = cellRepeater.itemAt(idx);
                if (cell)
                    cell.hasItem = false;
            }
        }
    }

    // Draggable component
    component DraggableArea: Item {
        id: dragger

        property Item subject
        property var positions
        default property alias data: tile.data
        property int col: 1
        property int row: 1
        width: 50 * col
        height: 50 * row

        onChildrenChanged: {
            for (let i = 0; i < children.length; i++) {
                if (children[i].hasOwnProperty("reparent")) {
                    const child = children[i];
                    if (child.reparent) {
                        children[i].parent = tile;
                    }
                }
            }
        }

        Connections {
            target: gridCellsContainer
            function onColumnsChanged() {
                if (dragger.parent === overlay) {
                    dragger.width = gridCellsContainer.width / gridCellsContainer.columns * dragger.col;
                }
            }
            function onRowsChanged() {
                if (dragger.parent === overlay) {
                    dragger.height = gridCellsContainer.height / gridCellsContainer.rows * dragger.row;
                }
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

            color: "transparent"
            border.width: 1
            border.color: Color.foreground

            // onChildrenChanged: {
            //     const child = children[0];
            //     if (child.column && child.row) {
            //         dragger.col = child.column;
            //         dragger.row = child.row;
            //         if (child.columnSpan && child.rowSpan) {
            //             const overlaps = root.updateCollision(dragger);
            //             // Compute bounding cells
            //             let rows = overlaps.map(c => c[0]);
            //             let cols = overlaps.map(c => c[1]);
            //             let row = Math.min(...rows);
            //             let lastRow = Math.max(...rows);
            //             let rowspan = lastRow - row + 1;
            //             let col = Math.min(...cols);
            //             let lastCol = Math.max(...cols);
            //             let colspan = lastCol - col + 1;
            //
            //             positions = {
            //                 row: row,
            //                 col: col,
            //                 rowspan: rowspan,
            //                 colspan: colspan
            //             };
            //
            //             dragger.parent = overlay;
            //
            //             // Cell sizes
            //             let cellWidth = gridCellsContainer.width / gridCellsContainer.columns;
            //             let cellHeight = gridCellsContainer.height / gridCellsContainer.rows;
            //             // Snap to grid
            //             dragger.x = col * cellWidth;
            //             dragger.y = row * cellHeight;
            //
            //             dragger.row = rowspan;
            //             dragger.col = colspan;
            //             dragger.width = colspan * cellWidth;
            //             dragger.height = rowspan * cellHeight;
            //             dragger.subject.reparent = true;
            //             dragger.subject.x = 0;
            //             dragger.subject.y = 0;
            //             root.draggableChanged(dragger, positions);
            //         }
            //     }
            // }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuad
                }
            }

            Drag.active: mouseArea.drag.active

            Drag.hotSpot.x: parent.width / 4
            Drag.hotSpot.y: parent.height / 4

            onXChanged: {
                if (!mouseArea.drag.active)
                    return;
                root.updateCollisionVisual(tile);
            }
            onYChanged: {
                if (!mouseArea.drag.active)
                    return;
                root.updateCollisionVisual(tile);
            }

            states: State {
                when: mouseArea.drag.active
                AnchorChanges {
                    target: tile
                    anchors {
                        verticalCenter: undefined
                        horizontalCenter: undefined
                    }
                }
                PropertyChanges {
                    target: tile
                    border.width: 2
                    border.color: Color.primary
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag.target: tile

            drag.onActiveChanged: {
                if (dragger.parent === overlay && drag.active) {
                    parent.width = width * 0.9;
                    parent.height = height * 0.9;
                    root.clearOccupiedCells(dragger.positions);

                    return;
                } else if (drag.active) {
                    parent.width = width * 0.9;
                    parent.height = height * 0.9;
                    return;
                }
            }

            onReleased: {
                // Get overlaps
                let overlaps = root.updateCollision(tile);
                const requiredMultiplier = Config.navbar.side ? dragger.subject.row : dragger.subject.column;
                if (overlaps.length < requiredMultiplier) {
                    dragger.parent = layoutItemContainer;
                    dragger.width = Config.navbar.side ? 50 : 50 * requiredMultiplier;
                    dragger.height = Config.navbar.side ? 50 * requiredMultiplier : 50;
                    dragger.subject.reparent = false;
                    return;
                }
                if (overlaps.length === 0) {
                    dragger.x = 0;
                    dragger.y = 0;
                    dragger.width = 50 * dragger.col;
                    dragger.height = 50 * dragger.row;
                    dragger.parent = layoutItemContainer;
                    root.draggableChanged(dragger, null);
                    dragger.subject.reparent = false;
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
                dragger.subject.reparent = true;
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
