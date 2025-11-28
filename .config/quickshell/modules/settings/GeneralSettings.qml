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

            // Layout Preview
            Item {
                visible: false
                Layout.fillWidth: true
                Layout.preferredHeight: 600

                GridLayout {
                    id: gridLayout
                    width: parent.width
                    height: 400
                    columns: columnCountBox.value
                    rows: rowCountBox.value

                    Repeater {
                        model: layoutAmmountBox.value

                        delegate: DropTile {
                            colorKey: "red"
                            column: 1
                            row: 1
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.columnSpan: column
                            Layout.rowSpan: row
                        }
                    }
                }
            }

            // Drag and Drop Grid
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 600
                visible: visible

                GridLayout {
                    id: grid

                    anchors {
                        top: redSource.bottom
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
                    id: redSource

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
