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
                        from: 1
                        to: 10
                    }
                    Label {
                        text: "row count"
                    }
                    SpinBox {
                        id: rowCountBox
                        from: 1
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
                    color: "blue"
                    column: 1
                    span: 1
                }
                ListElement {
                    color: "green"
                    column: 1
                    span: 1
                }
                ListElement {
                    color: "red"
                    column: 1
                    span: 1
                }
                ListElement {
                    color: "yellow"
                    column: 1
                    span: 1
                }
                ListElement {
                    color: "orange"
                    column: 1
                    span: 1
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: grid.implicitHeight

                GridLayout {
                    id: grid
                    columns: columnCountBox.value
                    rows: rowCountBox.value
                    columnSpacing: 5
                    rowSpacing: 5
                    uniformCellHeights: true
                    uniformCellWidths: true
                    Repeater {
                        model: colorModel
                        delegate: Item {
                            id: delegateItem
                            Layout.minimumWidth: 50
                            Layout.minimumHeight: 50

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Layout.rowSpan: model.span
                            Layout.columnSpan: model.column

                            Rectangle {
                                anchors.fill: parent
                                color: model.color
                                border.color: "gray"
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: mouse => {
                                    // Helper functions for clamping
                                    function clamp(val, min, max) {
                                        return Math.max(min, Math.min(max, val));
                                    }

                                    if (mouse.modifiers & Qt.ShiftModifier) {
                                        console.log("Shift clicked");
                                        if (mouse.button === Qt.RightButton) {
                                            model.span = clamp(model.span + 1, 1, grid.rows);
                                        } else if (mouse.button === Qt.LeftButton) {
                                            model.span = clamp(model.span - 1, 1, grid.rows);
                                        }
                                    } else if (mouse.modifiers & Qt.ControlModifier) {
                                        // ColumnSpan modification
                                        if (mouse.button === Qt.RightButton) {
                                            model.column = clamp(model.column + 1, 1, grid.columns);
                                        } else if (mouse.button === Qt.LeftButton) {
                                            model.column = clamp(model.column - 1, 1, grid.columns);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
