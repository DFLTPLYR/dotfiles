import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.components
import qs.assets

import qs.config
import qs.utils

Item {

    ScrollView {
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: width
        clip: true

        ColumnLayout {
            width: parent.width

            // Controls
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                width: parent.width   // Add this

                Flow {
                    anchors.fill: parent
                    spacing: 20
                    Column {
                        Label {
                            text: "column count"
                        }
                        SpinBox {
                            id: columnCountBox
                            from: 2
                            to: 10
                        }
                    }
                    Column {
                        Label {
                            text: "row count"
                        }
                        SpinBox {
                            id: rowCountBox
                            from: 2
                            to: 10
                        }
                    }
                    Column {
                        Label {
                            text: "layout ammount"
                        }
                        SpinBox {
                            id: layoutAmmountBox
                            from: 1
                            to: 20
                        }
                    }
                    Button {
                        text: "Reset Grid"
                        onClicked: {
                            for (let i = 0; i < overlay.children.length; i++) {
                                let child = overlay.children[i];

                                if (child instanceof Dragger) {
                                    for (let j in child.positions) {
                                        console.log(j, child.positions[j]);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Row {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                z: 10
                Repeater {
                    model: ScriptModel {
                        values: {
                            return Array.from({
                                length: layoutAmmountBox.value
                            }, (_, i) => i);
                        }
                    }
                    delegate: Dragger {
                        parentItem: overlay
                        color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
                    }
                }
            }

            Item {
                id: gridPreviewContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 400

                Rectangle {
                    anchors.fill: parent
                    color: "#444444"
                }

                function rectBounds(item) {
                    let p = item.mapToItem(null, 0, 0);
                    return {
                        x: p.x,
                        y: p.y,
                        width: item.width,
                        height: item.height
                    };
                }

                function intersects(a, b) {
                    return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#0000ff22"
                }

                Item {
                    id: overlay
                    anchors.fill: parent
                    z: 10
                }

                Grid {
                    id: gridPreview
                    anchors.fill: parent
                    columns: Math.max(1, columnCountBox.value)
                    rows: Math.max(1, rowCountBox.value)
                    spacing: 0

                    function updateCollision(dragItem) {
                        let overlaps = [];
                        for (let i = 0; i < repeater.count; i++) {
                            let cell = repeater.itemAt(i);
                            if (!cell)
                                continue;

                            let a = gridPreviewContainer.rectBounds(dragItem);
                            let b = gridPreviewContainer.rectBounds(cell);

                            if (gridPreviewContainer.intersects(a, b)) {
                                overlaps.push([Math.floor(i / columns), i % columns]);
                                cell.color = "#22ddff33";
                            } else {
                                cell.color = "transparent";
                            }
                        }
                        return overlaps;
                    }

                    Repeater {
                        id: repeater
                        model: columnCountBox.value * rowCountBox.value

                        delegate: Rectangle {
                            width: gridPreview.width / gridPreview.columns
                            height: gridPreview.height / gridPreview.rows
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

            // Drag and Drop Grid
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: false

                GridLayout {
                    id: grid

                    anchors {
                        top: modules.bottom
                        left: parent.left
                        right: parent.right
                        margins: 5
                    }

                    width: parent.width
                    height: 400
                    columns: columnCountBox.value
                    rows: rowCountBox.value

                    property int gridWidth: grid.width * columnCountBox.value + (columnCountBox.value - 1) * grid.gap
                    property int gridHeight: grid.height * rowCountBox.value + (rowCountBox.value - 1) * grid.gap
                    Repeater {
                        id: gridRepeater
                        model: ScriptModel {
                            values: {
                                return Array.from({
                                    length: layoutAmmountBox.value
                                }, (_, i) => i);
                            }
                        }

                        delegate: DropTile {
                            colorKey: "red"
                            column: 1
                            row: 1

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: grid.gridWidth / columnCountBox.value
                            Layout.preferredHeight: grid.gridHeight / rowCountBox.value
                            Layout.columnSpan: column
                            Layout.rowSpan: row

                            Text {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    horizontalCenter: parent.horizontalCenter
                                }
                                text: `${modelData + 1} \n(${column}x${row})`
                            }
                        }
                    }
                }

                Row {
                    id: modules

                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                        margins: 5
                    }

                    width: 64
                    spacing: -16

                    Repeater {
                        id: sourceRepeater
                        model: 2
                        delegate: DragTile {
                            colorKey: "red"
                        }
                    }
                }
            }
        }
    }

    component Dragger: Rectangle {
        id: dragger
        property Item parentItem: parent
        property var positions
        width: 50
        height: 50
        z: 999

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
                let overlaps = gridPreview.updateCollision(dragger);
                if (overlaps.length === 0)
                    return;

                // Compute bounding cells
                let rows = overlaps.map(c => c[0]);
                let cols = overlaps.map(c => c[1]);
                let row = Math.min(...rows);
                let lastRow = Math.max(...rows);
                let rowspan = lastRow - row + 1;
                let col = Math.min(...cols);
                let lastCol = Math.max(...cols);
                let colspan = lastCol - col + 1;
                dragger.parent = dragger.parentItem;
                if (dragger.parent) {
                    positions = {
                        row: row,
                        col: col,
                        rowspan: rowspan,
                        colspan: colspan
                    };
                }
                // Cell sizes
                let cellWidth = gridPreview.width / gridPreview.columns;
                let cellHeight = gridPreview.height / gridPreview.rows;

                // Snap to grid
                dragger.x = col * cellWidth;
                dragger.y = row * cellHeight;
                dragger.width = colspan * cellWidth;
                dragger.height = rowspan * cellHeight;
            }
        }
    }
}
