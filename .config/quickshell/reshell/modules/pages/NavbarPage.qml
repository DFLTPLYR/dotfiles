import QtQuick
import QtQuick.Layouts

import QtQml.Models

import qs.components
import qs.core

ColumnLayout {
    id: navbarpage

    property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
    property bool side: config ? (config.position === "left" || config.position === "right") : false

    Layout.fillWidth: true
    Layout.minimumHeight: 1

    // anchor position
    ColumnLayout {
        Layout.fillWidth: true

        Label {
            font.pixelSize: 32
            text: "Anchor Positions"
        }

        Row {
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

        Toggle {
            text: "Fill"
            checked: config.fill.enable
            onCheckedChanged: config.fill.enable = checked
        }

        // Fill options
        Column {
            spacing: 10

            Row {
                spacing: 10
                Label {
                    text: "width"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    enabled: config.fill.enable
                    stepSize: 1
                    from: 0
                    to: 100

                    value: config.fill.width
                    onValueChanged: config.fill.width = value
                }
            }
            Row {
                spacing: 10
                Label {
                    text: "height"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    enabled: config.fill.enable
                    stepSize: 1
                    from: 0
                    to: 100

                    value: config.fill.height
                    onValueChanged: config.fill.height = value
                }
            }
            Row {
                spacing: 10
                Label {
                    text: "axis"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    enabled: config.fill.enable
                    stepSize: 1
                    from: 0
                    to: 100

                    value: config.fill.axis
                    onValueChanged: config.fill.axis = value
                }
            }
        }

        Row {}
    }

    // layout slots
    ColumnLayout {
        Layout.fillWidth: true
        Row {
            spacing: 8
            Label {
                text: "Navbar Slots"
                font.pixelSize: 32
            }

            Button {
                text: "add"
                width: 60
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
    }

    // widgets
    FlexboxLayout {
        id: widgetContainer
        Layout.fillWidth: true

        Instantiator {
            model: ["clock", "bar", "other"]
            delegate: WidgetWrapper {}
            onObjectAdded: (idx, obj) => {
                obj.parent = widgetContainer;
            }
        }
    }

    component WidgetWrapper: Rectangle {
        id: origparent
        width: 80
        height: 80
        color: widget.parent === origparent ? Colors.setOpacity(Colors.color.background, 0.2) : Colors.color.background

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

        Rectangle {
            id: widget
            property int setHeight: 100
            property int setWidth: 100
            property int relativeX: 0
            property int relativeY: 0
            property int position: -1

            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)

            width: parent ? parent.width : 0
            height: parent ? parent.height : 0

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Drag.active: ma.drag.active

            Drag.hotSpot.x: width * 0.6
            Drag.hotSpot.y: height * 0.6
            Drag.keys: ["widget", widget.position]

            MouseArea {
                id: ma
                anchors.fill: parent
                drag.target: widget
                drag.axis: Drag.XAndYAxis
                onReleased: {
                    const dropArea = widget.Drag.target;
                    widget.Drag.drop();
                    if (!dropArea) {
                        widget.parent = origparent;
                        widget.x = 0;
                        widget.y = 0;
                        widget.width = origparent.width;
                        widget.height = origparent.height;
                        widget.position = -1;
                    }
                }
            }
        }
    }

    Footer {
        config: Global.getConfigManager(`${screen.name}-navbar`)
    }
}
