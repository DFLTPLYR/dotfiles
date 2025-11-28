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

            // Drag and Drop Grid
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: grid.implicitHeight
                visible: true

                FlexboxLayout {
                    id: grid
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
                        }
                    }
                }

                Row {
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
                        id: sourceRepeater
                        model: 2
                        delegate: DragTile {
                            colorKey: "red"
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 600
                FlexboxLayout {
                    id: flexLayout
                    anchors.fill: parent

                    wrap: FlexboxLayout.Wrap
                    direction: FlexboxLayout.Row

                    rowGap: 0
                    Rectangle {
                        color: 'teal'
                        implicitWidth: 200
                        implicitHeight: 200
                    }
                    Rectangle {
                        color: 'plum'
                        implicitWidth: 400
                        implicitHeight: 200
                    }
                    Rectangle {
                        color: 'olive'
                        implicitWidth: 200
                        implicitHeight: 200
                    }
                    Rectangle {
                        color: 'beige'
                        implicitWidth: 200
                        implicitHeight: 200
                    }
                    Rectangle {
                        color: 'darkseagreen'
                        implicitWidth: 200
                        implicitHeight: 200
                    }
                    Rectangle {
                        color: 'darkseagreen'
                        implicitWidth: 200
                        implicitHeight: 200
                    }
                }
            }
        }
    }
}
