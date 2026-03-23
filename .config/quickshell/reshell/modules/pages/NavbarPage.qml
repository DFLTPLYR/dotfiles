import Quickshell

import QtQuick
import QtQml.Models
import QtQuick.Layouts

import qs.core
import qs.components
import qs.components.widgets

Page {
    ColumnLayout {
        id: navbarpage
        property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
        property bool side: config ? (config.position === "left" || config.position === "right") : false
        width: parent.width
        spacing: 10

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
                        config.position = modelData;
                    }
                }
            }
        }

        Label {
            font.pixelSize: 32
            text: "Widgets and Slots"
        }

        // Fill options
        Row {
            spacing: 8
            Button {
                text: "Slots"
                width: 60
                onClicked: layoutSlot.opened ? layoutSlot.close() : layoutSlot.open()
            }

            Button {
                text: "widgets"
                onClicked: widgetPopup.opened ? widgetPopup.close() : widgetPopup.open()
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

                    value: config.width
                    onValueChanged: config.width = value
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

                    value: config.height
                    onValueChanged: config.height = value
                }
            }

            Row {
                spacing: 10
                Label {
                    text: config.side ? "y" : "x"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: sliderPos
                    stepSize: 1
                    from: 0
                    to: 100

                    value: config.side ? config.y : config.x
                    onValueChanged: {
                        if (config.side) {
                            config.y = value;
                        } else {
                            config.x = value;
                        }
                    }
                }

                Button {
                    text: 'center'
                    onClicked: {
                        const navsize = config.side ? config.height : config.width;
                        sliderPos.value = (100 - navsize) / 2;
                    }
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
            property var rounding: config.style.rounding

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
            property var margin: config.style.margin
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

        // widgets
        Popup {
            id: widgetPopup
            visible: opened && Global.enableSetting
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: parent.height

            contentItem: FlexboxLayout {
                id: widgetContainer

                Layout.fillWidth: true

                Instantiator {
                    id: widgetInstantiator
                    model: ScriptModel {
                        values: {
                            let widgets = Global.general.widgets.filter(widget => !navbarpage.config.widgets.some(w => w && widget && w.name === widget.objectName));
                            return [...widgets];
                        }
                    }
                    delegate: WidgetContainer {
                        model: `${modelData.objectName}.qml`
                    }
                    onObjectAdded: (idx, obj) => {
                        obj.parent = widgetContainer;
                    }
                }
            }
        }

        // layout slots
        Popup {
            id: layoutSlot
            visible: layoutSlot.opened && Global.enableSetting
            width: parent.width * 0.9
            height: parent.height
            clip: true

            contentItem: ColumnLayout {
                id: layoutPopup
                height: parent.height
                width: parent.width

                anchors {
                    margins: 4
                }

                Row {
                    Label {
                        text: "Slots"
                        font.pixelSize: 32
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Button {
                        text: "Add more"
                        onClicked: {
                            const layout = {
                                position: "left",
                                spacing: 2,
                                name: Math.random().toString(36).substring(2, 10)
                            };
                            config.layouts.push(layout);
                        }
                    }
                }

                ListView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    model: ScriptModel {
                        values: [...navbarpage.config.layouts]
                    }
                    clip: true
                    spacing: 4
                    orientation: ListView.Vertical
                    delegate: Rectangle {
                        id: slot
                        required property var modelData
                        width: parent ? parent.width : 0
                        height: 40
                        color: "transparent"
                        border {
                            width: 1
                            color: Colors.color.outline
                        }
                        GridLayout {
                            id: grid
                            anchors {
                                fill: parent
                            }

                            Repeater {
                                model: ['left', 'center', 'right']
                                delegate: Button {
                                    Layout.fillHeight: true
                                    width: height
                                    Layout.alignment: {
                                        switch (modelData) {
                                        case "left":
                                            return Qt.AlignLeft;
                                        case "center":
                                            return Qt.AlignCenter;
                                        case "right":
                                            return Qt.AlignRight;
                                        default:
                                            return Qt.AlignLeft;
                                        }
                                    }
                                    onClicked: {
                                        const target = navbarpage.config.layouts.find(s => s.name === slot.modelData.name);
                                        target.position = modelData;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Footer {
            onCancel: {
                const file = Global.getConfigManager(`${screen.name}-navbar`);
                file.rollbackHistory();
            }
            onSave: quit => {
                navbarpage.config.save();
                if (quit) {
                    Qt.callLater(() => {
                        Global.enableSetting = false;
                    });
                }
            }
        }
    }

    component WidgetContainer: Rectangle {
        id: origparent

        property string model
        property Item widget

        Layout.preferredWidth: navbarpage.side ? 40 : 120
        Layout.preferredHeight: navbarpage.side ? 120 : 40
        color: widget && widget.parent === origparent ? Colors.setOpacity(Colors.color.background, 0.2) : Colors.color.background

        Behavior on Layout.preferredWidth {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on Layout.preferredHeight {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        border {
            width: 1
            color: Colors.color.outline
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Loader {
            active: true
            source: {
                if (model !== "") {
                    return Quickshell.shellPath(`components/widgets/${origparent.model}`);
                } else {
                    return "";
                }
            }
            onItemChanged: {
                if (item) {
                    item.origparent = origparent;
                    item.parent = origparent;
                    origparent.widget = item;
                }
            }
            onStatusChanged: {
                if (status === Loader.Error) {
                    Global.general.widgets = Global.general.widgets.filter(s => s.objectName !== origparent.model.replace(/\.qml$/, ''));
                    Global.save();
                }
            }
        }
    }
}
