import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

Page {
    ColumnLayout {
        id: general
        property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
        property bool side: config ? (config.position === "left" || config.position === "right") : false
        width: parent.width

        clip: true

        Toggle {
            text: "Enable Greeter"
            checked: Global.general.greeter
            onCheckedChanged: {
                Global.general.greeter = checked;
                Global.save();
            }
        }

        Toggle {
            text: "Movable Setting Panel"
            checked: Global.general.moveablesetting
            onCheckedChanged: {
                Global.general.moveablesetting = checked;
                Global.save();
            }
        }

        // rounding
        Label {
            font.pixelSize: 32
            text: "Roundness"
        }

        Row {
            id: rounding
            property var rounding: Global.general.rounding

            Column {
                Label {
                    text: "Top Left"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: rounding.rounding.topLeft
                    onValueChanged: rounding.rounding.topLeft = value
                }
            }

            Column {
                Label {
                    text: "Top Right"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: rounding.rounding.topRight
                    onValueChanged: rounding.rounding.topRight = value
                }
            }

            Column {
                Label {
                    text: "Bottom Left"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: rounding.rounding.bottomLeft
                    onValueChanged: rounding.rounding.bottomLeft = value
                }
            }

            Column {
                Label {
                    text: "Bottom Right"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: rounding.rounding.bottomRight
                    onValueChanged: rounding.rounding.bottomRight = value
                }
            }
        }

        // margins
        Label {
            font.pixelSize: 32
            text: "Margins"
        }

        Row {
            id: margin
            property var margin: Global.general.margin
            Column {
                Label {
                    text: "Top"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: margin.margin.top
                    onValueChanged: margin.margin.top = value
                }
            }

            Column {
                Label {
                    text: "Bottom"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: margin.margin.bottom
                    onValueChanged: margin.margin.bottom = value
                }
            }

            Column {
                Label {
                    text: "Right"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: margin.margin.right
                    onValueChanged: margin.margin.right = value
                }
            }

            Column {
                Label {
                    text: "Left"
                }
                SpinBox {
                    width: 100
                    height: 20
                    value: margin.margin.left
                    onValueChanged: margin.margin.left = value
                }
            }
        }

        Label {
            font.pixelSize: 32
            text: "Docks"
        }

        ListView {
            height: contentHeight
            model: [...Global.docks]
            delegate: Button {
                text: modelData.objectName
                onClicked: Global.dockpanel = modelData
            }
        }

        Button {
            text: "add Dock"
            onClicked: {
                // docksPopup.opened ? docksPopup.close() : docksPopup.open()
                config.docks.push({
                    name: Math.random().toString(36).substring(2, 10)
                });
            }
        }

        // Popup {
        //     id: docksPopup
        //     width: parent.width * 0.95
        //     height: parent.height
        //     anchors.centerIn: parent
        //
        //     contentItem: FlexboxLayout {
        //         id: dockContainer
        //         focus: true
        //         Column {
        //             Label {
        //                 text: "Docks"
        //                 font.pixelSize: 32
        //             }
        //         }
        //         TextInput {
        //             id: dockName
        //             focus: true
        //             Layout.fillWidth: true
        //             Layout.preferredHeight: 40
        //         }
        //         Button {
        //             text: "Confirm"
        //             onClicked: {}
        //         }
        //     }
        // }

        Footer {
            onCancel: () => {
                console.log("test");
            }
            onSave: quit => {
                Global.save();
                if (quit) {
                    Qt.callLater(() => {
                        Global.enableSetting = false;
                    });
                }
            }
        }
    }
}
