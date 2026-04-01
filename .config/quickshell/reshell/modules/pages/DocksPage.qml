import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

Page {
    id: page
    property var selected: Global.docks[0] || {}
    property var config: selected.config
    property var panel: selected.panel

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
                    config.docks.push({
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
                values: [...Global.docks]
            }
            delegate: Button {
                text: modelData.panel.objectName
                onClicked: {
                    page.selected = modelData;
                    // Global.dockpanel = modelData.panel;
                }
            }
        }

        ColumnLayout {
            visible: page.selected
            Layout.fillWidth: true

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
            }
        }
    }
}
