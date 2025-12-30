import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs.components
import qs.utils
import qs.config
import qs.services

Item {
    id: root

    ScrollView {
        id: container
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: width
        clip: true

        ColumnLayout {
            width: parent.width
            Behavior on height {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    duration: 250
                }
            }
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
                Layout.fillHeight: true

                Flow {
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
                    Switch {
                        id: showPreviewButton
                        text: qsTr("Show Preview")
                    }
                }

                GridManager {
                    id: gridManager
                    property var screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
                    property int screenWidth: screen ? screen.width : 0
                    property int screenHeight: screen ? screen.height : 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    preferredHeight: Config.navbar.side ? root.height : Config.navbar.height
                    preferredWidth: Config.navbar.side ? Config.navbar.width : root.width
                    cellColumns: Config.navbar.side ? 1 : Config.navbar.cell
                    cellRows: Config.navbar.side ? Config.navbar.cell : 1

                    visible: !showPreviewButton.checked
                    z: 5

                    onDraggableChanged: (item, positions) => {
                        const name = item.subject.name;
                        const items = previewGrid.previewItems.slice();

                        const index = items.findIndex(i => i.name === name);

                        if (index !== -1) {
                            if (positions === null) {
                                items.splice(index, 1);
                            } else {
                                items[index] = {
                                    name,
                                    positions: {
                                        row: positions.row,
                                        column: positions.col,
                                        rowSpan: positions.rowspan,
                                        columnSpan: positions.colspan
                                    }
                                };
                            }
                        } else {
                            if (positions === null)
                                return;
                            items.push({
                                name,
                                positions: {
                                    row: positions.row,
                                    column: positions.col,
                                    rowSpan: positions.rowspan,
                                    columnSpan: positions.colspan
                                }
                            });
                        }

                        previewGrid.previewItems = items;
                    }

                    Component {
                        id: testRect
                        Item {
                            width: parent ? parent.width : 0
                            height: parent ? parent.height : 0
                            property int row: 2
                            property int column: 2
                            property int columnSpan: 2
                            property int rowSpan: 2
                            property bool reparent: false
                            property var position
                            property string name: "testRect"
                        }
                    }

                    Component {
                        id: clock
                        Item {
                            width: parent ? parent.width : 0
                            height: parent ? parent.height : 0
                            property int row: 2
                            property int column: 2
                            property int columnSpan: 2
                            property int rowSpan: 2
                            property bool reparent: false
                            property var position
                            property string name: "clock"
                            Text {
                                visible: !Config.navbar.side
                                anchors.centerIn: parent
                                text: Qt.formatDateTime(TimeService.clock.date, "hh:mm AP")
                                color: Color.color14
                                font {
                                    pixelSize: Math.min(20, Math.min(parent.width, parent.height))
                                }
                            }

                            Text {
                                visible: Config.navbar.side
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: Qt.formatDateTime(TimeService.clock.date, "hh mm AP")
                                color: Color.color2
                                width: parent.width
                                height: parent.height
                                font {
                                    pixelSize: Math.max(10, Math.min(parent.width, parent.height) * 0.5)
                                }
                                style: Text.Outline
                                styleColor: Color.color15
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Component {
                        id: workspace
                        Row {
                            width: reparent ? parent.width : 50
                            height: reparent ? parent.height : 50
                            property int row: 2
                            property int column: 2
                            property int columnSpan: 2
                            property int rowSpan: 2
                            property bool reparent: false
                            property var position
                            property string name: "workspace"
                            Repeater {
                                model: Hyprland.workspaces
                                delegate: Rectangle {
                                    required property var modelData
                                    width: Config.navbar.side ? parent.width : parent.height
                                    height: Config.navbar.side ? parent.width : parent.height
                                    visible: modelData.focused
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

            Rectangle {
                visible: showPreviewButton.checked
                Layout.preferredHeight: Config.navbar.side ? root.height : Config.navbar.height
                Layout.preferredWidth: Config.navbar.side ? Config.navbar.width : root.width
                color: Scripts.setOpacity(Color.background, 0.5)

                GridLayout {
                    id: previewGrid
                    property var previewItems: []
                    anchors.fill: parent
                    columns: Config.navbar.side ? 1 : Config.navbar.cell
                    rows: Config.navbar.side ? Config.navbar.cell : 1
                    rowSpacing: 0
                    columnSpacing: 0

                    Repeater {
                        model: ScriptModel {
                            values: {
                                const items = previewGrid.previewItems;
                                return items;
                            }
                        }
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.row: modelData.positions.row
                            Layout.column: modelData.positions.column
                            Layout.rowSpan: modelData.positions.rowSpan
                            Layout.columnSpan: modelData.positions.columnSpan
                            Layout.minimumWidth: previewGrid.width / previewGrid.columns * modelData.positions.columnSpan
                            Layout.minimumHeight: previewGrid.height / previewGrid.rows * modelData.positions.rowSpan
                            Layout.alignment: Qt.AlignBaseline
                            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
                            Text {
                                text: "colSpan: " + modelData.positions.columnSpan + ", rowSpan: " + modelData.positions.rowSpan
                                anchors.centerIn: parent
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
                preferredWidth: root.width
                preferredHeight: root.height * 0.5
                Layout.preferredHeight: 400

                cellColumns: columnCountBox.value
                cellRows: rowCountBox.value

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
