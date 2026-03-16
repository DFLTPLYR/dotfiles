import Quickshell

import QtQuick
import QtQml.Models
import QtQuick.Layouts

import qs.core
import qs.components
import qs.components.widgets

ColumnLayout {
    id: navbarpage
    property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
    property bool side: config ? (config.position === "left" || config.position === "right") : false

    Layout.fillWidth: true
    Layout.minimumHeight: 1

    ColumnLayout {
        Layout.fillWidth: true

        RowLayout {
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
        }

        // Fill options

        Row {
            spacing: 8

            Button {
                text: "Slots"
                width: 60
                // onClicked: {
                // const layout = {
                //     position: "left",
                //     spacing: 2,
                //     name: Math.random().toString(36).substring(2, 10)
                // };
                // config.layouts.push(layout);
                // }
                onClicked: layoutSlot.opened ? layoutSlot.close() : layoutSlot.open()
            }
            Button {
                text: "widgets"
                onClicked: widgetPopup.opened ? widgetPopup.close() : widgetPopup.open()
            }
        }

        Toggle {
            text: "Fill"
            checked: config.fill.enable
            onCheckedChanged: config.fill.enable = checked
        }
    }

    Column {
        visible: config.fill.enable || false
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

    // widgets
    Popup {
        id: widgetPopup
        visible: opened && Global.enableSetting
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height

        FlexboxLayout {
            id: widgetContainer

            Layout.fillWidth: true

            Instantiator {
                id: widgetInstantiator
                active: false
                delegate: WidgetContainer {
                    model: `${modelData.objectName}.qml`
                }
                onObjectAdded: (idx, obj) => {
                    obj.parent = widgetContainer;
                }
            }

            Component.onCompleted: {
                Global.general.onWidgetsChanged.connect(() => {
                    if (Global.general.widgets.length !== 0) {
                        const model = widgetmodel.createObject(null, {
                            values: [...Global.general.widgets]
                        });
                        widgetInstantiator.model = model;
                        widgetInstantiator.active = true;
                    }
                });
            }
        }
    }

    Component {
        id: widgetmodel
        ScriptModel {}
    }

    Popup {
        id: layoutSlot
        visible: opened && Global.enableSetting
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: navbarpage.height
        focus: true

        Repeater {}
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
                    const file = Global.getConfigManager(`${screen.name}-navbar`);
                    const exists = file.widgets.some(w => w && w.objectName === item.objectName);
                    if (!exists) {
                        file.widgets.push(item);
                    }
                }
            }
        }
    }

    Footer {
        config: Global.getConfigManager(`${screen.name}-navbar`)
    }
}
