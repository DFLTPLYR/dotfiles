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

                RowLayout {
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
                }
            }

            // Drag and Drop Grid
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: grid.implicitHeight
                visible: true

                Grid {
                    id: grid

                    anchors {
                        left: redSource.right
                        top: parent.top
                        right: parent.right
                        margins: 5
                    }

                    spacing: 2
                    opacity: 0.5

                    columns: columnCountBox.value
                    rows: rowCountBox.value

                    Repeater {
                        id: gridRepeater
                        model: ScriptModel {
                            values: {
                                const count = columnCountBox.value * rowCountBox.value;
                                return Array(count).fill(null);
                            }
                        }
                        delegate: DropTile {
                            colorKey: "red"
                        }
                    }
                }

                Column {
                    id: redSource

                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                        margins: 5
                    }

                    width: 64
                    spacing: -16

                    Repeater {
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
