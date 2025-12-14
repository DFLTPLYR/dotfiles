import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs.components

import qs.config

Item {
    id: root

    ScrollView {
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: width
        clip: true

        ColumnLayout {
            width: parent.width

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "<h1>Navbar Configurations</h1>"
                font.bold: true
                font.pointSize: 12
                color: Color.text
            }

            // Navbar modules
            ColumnLayout {
                Layout.fillWidth: true

                Column {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Label {
                        text: "Cell count"
                    }
                    SpinBox {
                        id: cellCount
                        from: 2
                        value: Config.navbar.cell
                        onValueChanged: {
                            Config.navbar.cell = value;
                        }
                    }
                }

                GridManager {
                    id: gridManager

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    cellColumns: Config.navbar.side ? 1 : Config.navbar.cell
                    cellRows: Config.navbar.side ? Config.navbar.cell : 1

                    z: 5

                    onDraggableChanged: (item, positions) => {
                        for (let key in item.positions) {
                            console.log(" ", key, ":", item.positions[key]);
                        }
                    }

                    Component {
                        id: testRect
                        Item {
                            width: reparent ? parent.width : 0
                            height: reparent ? parent.height : 0
                            property int cellSize: 1
                            property bool reparent: false
                            property var position
                        }
                    }

                    Component {
                        id: clock
                        Item {
                            width: reparent ? parent.width : 50
                            height: reparent ? parent.height : 50
                            property int cellSize: 2
                            property bool reparent: false
                            property var position
                            Text {
                                text: "clock"
                            }
                        }
                    }

                    Component {
                        id: workspace
                        Row {
                            width: reparent ? parent.width : 50
                            height: reparent ? parent.height : 50
                            property int cellSize: 1
                            property bool reparent: false
                            property var position
                            Repeater {
                                model: Hyprland.workspaces
                                delegate: Rectangle {
                                    required property var modelData
                                    visible: modelData.id !== 0 && modelData.focused && modelData.active
                                    width: parent.height
                                    height: parent.height
                                    color: "red"
                                    border.color: "black"
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.id
                                    }
                                }
                            }
                        }
                    }

                    Variants {
                        model: Config.navbar.modules
                        delegate: LazyLoader {
                            id: loader
                            property var modelData
                            Component.onCompleted: {
                                const model = modelData.module;
                                switch (model) {
                                case "clock":
                                    component = clock;
                                    break;
                                case "workspaces":
                                    component = workspace;
                                    break;
                                default:
                                    component = testRect;
                                    break;
                                }
                                active = true;
                            }
                            onItemChanged: {
                                item.parent = gridManager;
                                item.position = modelData.position;
                            }
                        }
                    }
                }
            }

            // workspace style settings
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: Config.navbar.extended.styles
                    delegate: RadioButton {
                        required property var modelData
                        checked: Config.navbar.extended.style === modelData
                        text: modelData
                        onCheckedChanged: {
                            if (checked) {
                                Config.navbar.extended.style = modelData;
                            }
                        }
                    }
                }
            }

            // Position Settings
            RowLayout {
                Layout.fillWidth: true
                RadioButton {
                    checked: Config.navbar.position === "top"
                    text: qsTr("Top")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "top";
                            Config.navbar.side = false;
                        }
                    }
                }
                RadioButton {
                    checked: Config.navbar.position === "bottom"
                    text: qsTr("Bottom")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "bottom";
                            Config.navbar.side = false;
                        }
                    }
                }
                RadioButton {
                    checked: Config.navbar.position === "right"
                    text: qsTr("Right")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "right";
                            Config.navbar.side = true;
                        }
                    }
                }
                RadioButton {
                    checked: Config.navbar.position === "left"
                    text: qsTr("Left")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "left";
                            Config.navbar.side = true;
                        }
                    }
                }
            }

            // width/height settings
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        visible: !Config.navbar.side
                        text: "Height"
                    }
                    Slider {
                        visible: !Config.navbar.side
                        Layout.fillWidth: true
                        from: 40
                        value: Config.navbar.height
                        to: 100
                        onValueChanged: {
                            Config.navbar.height = value;
                        }
                    }
                    Label {
                        visible: Config.navbar.side
                        text: "Width"
                    }
                    Slider {

                        visible: Config.navbar.side
                        Layout.fillWidth: true
                        from: 40
                        value: Config.navbar.width
                        to: 100
                        onValueChanged: {
                            Config.navbar.width = value;
                        }
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: "<h2>Extended Bar Settings</h2>"
            }

            // Axis position extendedbar settings
            RowLayout {
                visible: Config.navbar.position === "top" || Config.navbar.position === "bottom"
                Layout.fillWidth: true
                Label {
                    text: "Popup X Position"
                }
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 99
                    value: Config.navbar.popup.x
                    onValueChanged: {
                        Config.navbar.popup.x = value;
                    }
                }
            }

            RowLayout {
                visible: Config.navbar.position === "left" || Config.navbar.position === "right"
                Layout.fillWidth: true
                Label {
                    text: "Popup Y Position"
                }
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: Config.navbar.popup.y
                    onValueChanged: {
                        Config.navbar.popup.y = value;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        text: "Popup Height"
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 10
                        value: Config.navbar.popup.height
                        to: 100
                        onValueChanged: {
                            Config.navbar.popup.height = value;
                        }
                    }
                }
                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        text: "Popup Width"
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 10
                        value: Config.navbar.popup.width
                        to: 100
                        onValueChanged: {
                            Config.navbar.popup.width = value;
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Column {
                    Label {
                        text: "column count"
                    }
                    SpinBox {
                        id: columnCountBox
                        from: 2
                        to: 10
                        value: Config.navbar.extended.columns
                        onValueChanged: {
                            Config.navbar.extended.columns = value;
                        }
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
                        value: Config.navbar.extended.rows
                        onValueChanged: {
                            Config.navbar.extended.rows = value;
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

                z: 5
                onDraggableChanged: (item, positions) => {
                    for (let key in item.positions) {
                        console.log(" ", key, ":", item.positions[key]);
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Save Settings"
                }
                Button {
                    text: "Save"
                    onClicked: {
                        Config.saveSettings();
                    }
                }
            }
        }
    }
}
