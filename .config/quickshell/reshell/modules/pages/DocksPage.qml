import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

Page {
    id: page
    required property list<var> docks

    property var selected: null
    property var config: selected ? selected.config : null
    property var panel: selected ? selected.panel : null

    signal remove(var item)

    ColumnLayout {
        width: parent.width

        Row {
            Layout.fillWidth: true
            spacing: 4

            Label {
                font.pixelSize: 32
                text: "Docks"
            }

            Button {
                text: "add Dock"
                onClicked: {
                    page.windowconfig.docks.push({
                        name: Math.random().toString(36).substring(2, 10)
                    });
                }
            }
        }

        ListView {
            id: docklist
            width: docklist.contentWidth
            implicitHeight: 40
            orientation: ListView.Horizontal
            model: ScriptModel {
                values: [...page.docks].filter(s => s.config !== null)
            }
            delegate: Button {
                required property var modelData
                text: modelData.panel.objectName
                TapHandler {
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onTapped: (eventPoint, button) => {
                        if (button === Qt.LeftButton) {
                            page.selected = modelData;
                        } else if (button === Qt.RightButton) {
                            page.remove(modelData.panel.objectName);
                            page.selected = docklist.model.values[0] || null;
                        }
                    }
                }
                Component.onCompleted: {
                    if (page.selected === null) {
                        page.selected = modelData;
                    }
                }
            }
            Component.onCompleted: {
                page.selected = docklist.model.values[0] || null;
            }
        }

        Loader {
            active: page.selected
            sourceComponent: Content {}
        }
    }

    component Content: ColumnLayout {
        visible: page.selected
        Layout.fillWidth: true

        Label {
            font.pixelSize: 32
            text: "Dock Content"
        }

        Row {
            Button {
                text: "Widgets"
                onClicked: {
                    Global.widgetpanelEnabled = true;
                    Global.widgetpanelTarget = page.selected.panel;
                }
            }

            Button {
                text: "Slots"
            }
        }

        Label {
            font.pixelSize: 32
            text: "Anchor Positions"
        }

        Row {
            spacing: 2
            Repeater {
                id: positions
                model: ["left", "top", "right", "bottom"]
                delegate: Button {
                    required property string modelData
                    text: modelData
                    onClicked: {
                        page.config.position = modelData;
                    }
                }
            }
        }

        Label {
            font.pixelSize: 32
            text: "Navbar Dimensions"
        }

        Column {
            spacing: 10
            // Width
            Row {
                spacing: 10
                Label {
                    text: "Width"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    stepSize: 1
                    from: 0
                    to: 100

                    value: page.config.width
                    onValueChanged: page.config.width = value
                }
            }
            // Height
            Row {
                spacing: 10
                Label {
                    text: "Height"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    stepSize: 1
                    from: 0
                    to: 100

                    value: page.config.height
                    onValueChanged: page.config.height = value
                }
            }
            // Position
            Row {
                spacing: 10
                Label {
                    text: page.config.side ? "y" : "x"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: sliderPos
                    property int barsize: page.config.side ? page.config.height : page.config.width
                    enabled: barsize !== 100

                    from: 0
                    to: 100
                    stepSize: 1

                    value: page.config.side ? page.config.y : page.config.x

                    onValueChanged: {
                        if (page.config.side) {
                            page.config.y = value;
                        } else {
                            page.config.x = value;
                        }
                    }
                }

                Button {
                    text: "center"
                    onClicked: {
                        sliderPos.value = 50;
                    }
                }
            }

            // rounding
            Label {
                font.pixelSize: 32
                text: "Roundness"
            }
            Row {
                id: rounding
                property var rounding: page.config.style.rounding

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
                property var margin: page.config.style.margin
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
        }
    }
}
