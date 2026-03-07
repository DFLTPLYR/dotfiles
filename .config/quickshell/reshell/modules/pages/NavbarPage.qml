import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models

import qs.components.widgets
import qs.components
import qs.core

ColumnLayout {
    id: navbarpage

    property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
    property bool side: config ? (config.position === "left" || config.position === "right") : false

    Layout.fillWidth: true
    Layout.minimumHeight: 1
 
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
            model: ["Clock.qml"]
            delegate: WidgetContainer {}
            onObjectAdded: (idx, obj) => {
                obj.model = model[idx];
                obj.parent = widgetContainer;
            }
        }
    }

    component WidgetContainer: Rectangle {
        id: origparent

        property string model
        property Item widget

        width: navbarpage.side ? 40 : 120
        height: navbarpage.side ? 120 : 40
        color: widget && widget.parent === origparent ? Colors.setOpacity(Colors.color.background, 0.2) : Colors.color.background

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

        LazyLoader {
            active: true
            source: {
                if (model !== "") {
                    return Quickshell.shellPath(`components/widgets/${origparent.model}`);
                } else {
                    return "";
                }
            }
            onLoadingChanged: {
                if (item) {
                    item.origparent = origparent;
                    item.parent = origparent;
                    origparent.widget = item;
                }
            }
        }
    }

    Footer {
        config: Global.getConfigManager(`${screen.name}-navbar`)
    }
}
