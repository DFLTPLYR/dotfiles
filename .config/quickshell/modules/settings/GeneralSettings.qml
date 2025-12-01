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

            GridManager {
                id: gridPreviewContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 400

                cellColumns: columnCountBox.value
                cellRows: rowCountBox.value
                layoutAmmount: layoutAmmountBox.value

                z: 5
                onDraggableChanged: (item, positions) => {
                    console.log(" Draggables changed:", positions, item);
                    for (let key in item.positions) {
                        console.log(" ", key, ":", item.positions[key]);
                    }
                }
                Repeater {
                    model: ScriptModel {
                        values: {
                            return Array.from({
                                length: layoutAmmountBox.value
                            }, (_, i) => {
                                return {
                                    id: "item_" + i,
                                    name: "Item " + (i + 1)
                                };
                            });
                        }
                    }
                    delegate: Item {
                        width: 50
                        height: 50
                        property bool reparent: true
                    }
                }
            }
        }
    }
}
