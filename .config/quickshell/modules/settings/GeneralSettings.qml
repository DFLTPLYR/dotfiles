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

                Flow {
                    Layout.fillWidth: true
                    Label {
                        text: "column count"
                    }
                    SpinBox {
                        id: columnCountBox
                        from: 2
                        to: 10
                    }
                    Label {
                        text: "row count"
                    }
                    SpinBox {
                        id: rowCountBox
                        from: 2
                        to: 10
                    }
                    Label {
                        text: "Layout Ammount"
                    }
                    SpinBox {
                        id: layoutAmmountBox
                        from: 1
                        to: columnCountBox.value * rowCountBox.value
                    }
                }
            }

            Rectangle {
                id: dragger
                width: 60
                height: 100
                color: "red"
                z: 999

                // When dragger moves, tell the grid to update collisions
                onXChanged: gridPreview.updateCollision()
                onYChanged: gridPreview.updateCollision()

                MouseArea {
                    anchors.fill: parent
                    drag.target: parent
                    onReleased: {
                        let overlaps = gridPreview.updateCollision(); // [[row, col], ...]
                        if (overlaps.length === 0)
                            return;
                        overlaps.sort((a, b) => a[0] - b[0] || a[1] - b[1]);

                        let first = overlaps[0];
                        let last = overlaps[overlaps.length - 1];

                        let row = first[0];
                        let rowspan = last[0] - first[0] + 1;
                        let col = first[1];
                        let colspan = last[1] - first[1] + 1;
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

                Grid {
                    id: gridPreview
                    anchors.fill: parent
                    columns: columnCountBox.value

                    // Function called whenever dragger moves
                    function updateCollision() {
                        let overlaps = [];
                        for (let i = 0; i < repeater.count; i++) {
                            let cell = repeater.itemAt(i);
                            if (!cell)
                                continue;

                            let pos = cell.updateOverlap(i);
                            if (pos)
                                overlaps.push(pos);
                        }
                        return overlaps;
                    }

                    Repeater {
                        id: repeater
                        model: columnCountBox.value * rowCountBox.value

                        delegate: Rectangle {
                            id: cell

                            width: gridPreview.width / columnCountBox.value
                            height: gridPreview.height / rowCountBox.value

                            color: "transparent"
                            border.color: "green"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData + 1
                            }

                            // Update overlap and log row/column
                            function updateOverlap(index) {
                                let a = gridPreviewContainer.rectBounds(dragger);
                                let b = gridPreviewContainer.rectBounds(cell);

                                if (gridPreviewContainer.intersects(a, b)) {
                                    cell.color = "#22ddff33";
                                    let row = Math.floor(index / columnCountBox.value);
                                    let column = index % columnCountBox.value;
                                    console.log("Overlap at row:", row, "column:", column);
                                    return [row, column];
                                } else {
                                    cell.color = "transparent";
                                }
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
}
