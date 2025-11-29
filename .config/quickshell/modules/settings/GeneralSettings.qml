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

    FileView {
        id: persistentLayoutView
        path: Qt.resolvedUrl("./layout.json")
        watchChanges: true
        preload: true
        onFileChanged: {
            reload();
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                persistentLayoutView.setText("{}");
                persistentLayoutView.writeAdapter();
            }
        }
        JsonAdapter {
            id: adapter
            property var layoutItems: []
        }
    }

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
                id: controls

                Layout.fillWidth: true
                Layout.preferredHeight: controlFlow.implicitHeight

                Flow {
                    id: controlFlow
                    anchors.fill: parent
                    spacing: 20
                    width: parent.width

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
                        text: "Reset"
                        onClicked: {
                            persistentLayoutView.adapter.layoutItems = [];
                            persistentLayoutView.writeAdapter();
                        }
                    }
                    Button {
                        text: "Save Layout"
                        onClicked: {
                            let items = persistentLayoutView.adapter.layoutItems.slice(); // copy

                            for (let child of overlay.children) {
                                if (child instanceof Dragger) {
                                    // deep copy positions if needed
                                    const snapshot = JSON.parse(JSON.stringify(child.positions));
                                    items.push(snapshot);
                                }
                            }
                            persistentLayoutView.adapter.layoutItems = items;
                            persistentLayoutView.writeAdapter();
                        }
                    }
                }
            }

            Row {
                id: draggablesContainer
                Layout.fillWidth: true
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
                        col: Scripts.getRandomInt(3)
                        row: Scripts.getRandomInt(3)
                        width: row * 50
                        height: col * 50
                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
                            border.color: "black"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "Mpris"
                            }
                        }
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

                Rectangle {
                    anchors.fill: parent
                    color: "#0000ff22"
                }

                Item {
                    id: overlay
                    anchors.fill: parent
                    z: 10
                    onChildrenChanged: {
                        for (let child of children) {
                            console.log(" Child:", child);
                        }
                    }
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

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 400

                GridLayout {
                    id: previewGrid
                    anchors.fill: parent
                    columns: Math.max(1, columnCountBox.value)
                    rows: Math.max(1, rowCountBox.value)

                    Repeater {
                        model: persistentLayoutView.adapter.layoutItems
                        Rectangle {
                            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.2)
                            border.color: "black"
                            border.width: 2

                            // Map JSON layout properties to GridLayout
                            Layout.row: modelData.row
                            Layout.column: modelData.col
                            Layout.rowSpan: modelData.rowspan
                            Layout.columnSpan: modelData.colspan
                            // Use preferred sizes, not width/height
                            Layout.preferredWidth: modelData.colspan * (previewGrid.width / previewGrid.columns)
                            Layout.preferredHeight: modelData.rowspan * (previewGrid.height / previewGrid.rows)

                            // optional to avoid auto stretching
                            Layout.fillWidth: false
                            Layout.fillHeight: false
                        }
                    }
                }
            }
        }
    }

    component Dragger: Item {
        id: dragger
        property Item parentItem: parent
        property var positions
        property int col: 1
        property int row: 1

        width: 50 * row
        height: 50 * col

        z: 2

        onRowChanged: {
            width = Math.min(50, 50 * row);
        }
        onColChanged: {
            height = Math.min(50, 50 * col);
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
                let overlaps = gridPreview.updateCollision(dragger);
                if (overlaps.length === 0) {
                    dragger.x = 0;
                    dragger.y = 0;
                    dragger.width = 50 * dragger.row;
                    dragger.height = 50 * dragger.col;
                    dragger.parent = draggablesContainer;
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
                let cellWidth = gridPreview.width / gridPreview.columns;
                let cellHeight = gridPreview.height / gridPreview.rows;

                // Snap to grid
                dragger.x = col * cellWidth;
                dragger.y = row * cellHeight;
                dragger.row = rowspan;
                dragger.col = colspan;
                dragger.width = colspan * cellWidth;
                dragger.height = rowspan * cellHeight;
            }
        }

        WheelHandler {
            id: wheelHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            onWheel: event => {
                if (mouseArea.drag.active) {
                    const isShift = event.modifiers & Qt.ShiftModifier;
                    const isCtrl = event.modifiers & Qt.ControlModifier;
                    const scrollup = event.angleDelta.y > 0;

                    if (scrollup && isShift) {
                        dragger.col = Math.min(dragger.col + 1, gridPreview.columns);
                    } else if (!scrollup && isShift) {
                        dragger.col = Math.max(dragger.col - 1, 1);
                    } else if (scrollup && isCtrl) {
                        dragger.row = Math.min(dragger.row + 1, gridPreview.rows);
                    } else if (!scrollup && isCtrl) {
                        dragger.row = Math.max(dragger.row - 1, 1);
                    }
                }
            }
        }
    }
}
