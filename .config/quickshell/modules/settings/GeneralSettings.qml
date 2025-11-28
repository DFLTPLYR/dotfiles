import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.components
import qs.assets

import qs.config

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

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "column count"
                    }
                    SpinBox {
                        id: columnCountBox
                        from: 4
                        to: 10
                    }
                    Label {
                        text: "row count"
                    }
                    SpinBox {
                        id: rowCountBox
                        from: 4
                        to: 10
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Rectangle {
                    anchors.fill: parent
                }
            }

            ListModel {
                id: colorModel
                ListElement {
                    row: 0
                    col: 0
                    color: "red"
                    span: 1
                    column: 1
                }
                ListElement {
                    row: 1
                    col: 1
                    color: "blue"
                    span: 1
                    column: 1
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: grid.implicitHeight
                visible: true

                GridLayout {
                    id: grid

                    columns: Math.max(4, columnCountBox.value)
                    rows: Math.max(4, rowCountBox.value)

                    Repeater {
                        id: inst
                        model: colorModel

                        delegate: Item {
                            id: delegateItem
                            // NOTE: Instantiator does not parent automatically.

                            Layout.row: model.row
                            Layout.column: model.col
                            Layout.rowSpan: model.span
                            Layout.columnSpan: model.column
                            width: 50 * model.column
                            height: 50 * model.span

                            Rectangle {
                                id: rectTarget
                                anchors.fill: parent
                                color: model.color
                                border.color: "gray"
                                Text {
                                    anchors.centerIn: parent
                                    text: "C: " + column + "\nS: " + span
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                drag.target: delegateItem
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                Drag.active: mouseArea.drag.active
                                Drag.hotSpot.x: mouseArea.x
                                Drag.hotSpot.y: mouseArea.y
                                Drag.keys: [index]

                                onReleased: Drag.drop()

                                onClicked: mouse => {
                                    if (mouseArea.drag.active)
                                        return;
                                    function clamp(val, min, max) {
                                        return Math.max(min, Math.min(max, val));
                                    }

                                    switch (mouse.button) {
                                    case Qt.RightButton:
                                        if (mouse.modifiers & Qt.ShiftModifier)
                                            span = clamp(span + 1, 1, grid.rows);
                                        else if (mouse.modifiers & Qt.ControlModifier)
                                            column = clamp(column + 1, 1, grid.columns);
                                        break;
                                    case Qt.LeftButton:
                                        if (mouse.modifiers & Qt.ShiftModifier)
                                            span = clamp(span - 1, 1, grid.rows);
                                        else if (mouse.modifiers & Qt.ControlModifier)
                                            column = clamp(column - 1, 1, grid.columns);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                GridLayout {
                    id: blackGrid
                    columns: Math.max(1, columnCountBox.value)
                    rows: Math.max(1, rowCountBox.value)

                    Repeater {
                        model: grid.rows * grid.columns
                        delegate: DropArea {
                            id: dragTarget
                            property int dropRow: index / parent.columns
                            property int dropCol: index % parent.columns

                            Layout.minimumWidth: dragTarget.containsDrag ? 60 : 50
                            Layout.minimumHeight: dragTarget.containsDrag ? 60 : 50

                            Rectangle {
                                anchors.fill: parent
                                color: dragTarget.containsDrag ? "grey" : "transparent"
                                border.color: "gray"
                            }

                            onDropped: drag => {
                                const itemIndex = drag.keys[0];
                                colorModel.setProperty(itemIndex, "row", dropRow);
                                colorModel.setProperty(itemIndex, "col", dropCol);
                            }
                        }
                    }
                }
            }

            Button {
                text: "test"
                Layout.preferredWidth: 50
                Layout.fillHeight: true
                onClicked: {
                    for (let i = 0; i < colorModel.count; i++) {
                        console.log("Item " + i + ": row=" + colorModel.get(i).row + ", col=" + colorModel.get(i).col);
                    }
                }
            }
        }
    }
}
