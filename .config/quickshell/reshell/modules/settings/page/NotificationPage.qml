pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.types
import qs.components
import qs.modules.settings
import qs.modules.overlay.notifications

Page {
    id: page
    property bool perMonitor: false
    property var config: Global.getConfig().adapter.notification

    property QtObject previewStyle: Style {
        Component.onCompleted: {
            const s = page.config.style;
            color = s.color;
            padding.top = s.padding.top;
            padding.bottom = s.padding.bottom;
            padding.left = s.padding.left;
            padding.right = s.padding.right;
            inset.top = s.inset.top;
            inset.bottom = s.inset.bottom;
            inset.left = s.inset.left;
            inset.right = s.inset.right;
            background.rounding.topLeft = s.background.rounding.topLeft;
            background.rounding.topRight = s.background.rounding.topRight;
            background.rounding.bottomLeft = s.background.rounding.bottomLeft;
            background.rounding.bottomRight = s.background.rounding.bottomRight;
            background.margins.top = s.background.margins.top;
            background.margins.bottom = s.background.margins.bottom;
            background.margins.left = s.background.margins.left;
            background.margins.right = s.background.margins.right;
        }
    }

    property var previewExample: {
        "notificationId": 69,
        "actions": [
            {
                "identifier": "default",
                "text": "Activate"
            }
        ],
        "appIcon": "firefox",
        "appName": "firefox",
        "body": "This is the text body of the notification. \nPretty cool, huh?",
        "image": "",
        "summary": "Notification Example",
        "time": 1777989368250,
        "urgency": "1"
    }

    grid.data: [
        Button {
            id: monitorMenu
            visible: Quickshell.screens.length > 1
            text: "Set"
            onClicked: popup.opened ? popup.close() : popup.open()

            Menu {
                id: popup
                y: -height
                x: -popup.width / 2

                Instantiator {
                    model: Quickshell.screens
                    delegate: Action {
                        required property ShellScreen modelData
                        text: modelData.name
                    }
                    onObjectAdded: (idx, obj) => {
                        popup.insertAction(idx, obj);
                    }
                }
            }
        },
        Button {
            text: "Apply"
        }
    ]

    Content {}

    Properties {}

    component Grid: Canvas {
        clip: false
        onPaint: {
            var ctx = getContext("2d");
            var gridSize = 10;

            ctx.strokeStyle = Colors.setOpacity(Colors.theme.on_surface, 0.5);
            ctx.lineWidth = 1;

            for (var x = 0; x <= width; x += gridSize) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, height);
                ctx.stroke();
            }

            for (var y = 0; y <= height; y += gridSize) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
        }
    }

    component Content: GroupContainer {
        label: "Notification Item"

        Rectangle {
            color: "transparent"
            radius: 5
            height: page.height * 0.4

            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }

            border {
                width: 1
                color: Colors.theme.on_surface
            }

            Flickable {
                id: content

                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                acceptedButtons: Qt.MiddleButton | Qt.LeftButton
                clip: true

                contentX: (contentWidth - width) / 2
                contentY: (contentHeight - height) / 2
                transformOrigin: Item.Center

                Grid {
                    anchors.fill: parent
                }

                NotificationItem {
                    id: notificationItem
                    ma.enabled: false
                    style: page.previewStyle
                    width: page.config.width
                    height: page.config.height

                    // Notification Bg
                    bg {
                        color: style.color

                        bottomRightRadius: style.background.rounding.bottomRight
                        bottomLeftRadius: style.background.rounding.bottomLeft
                        topRightRadius: style.background.rounding.topRight
                        topLeftRadius: style.background.rounding.topLeft
                    }

                    modelData: page.previewExample

                    Component.onCompleted: {
                        x = (parent.width - width) / 2;
                        y = (parent.height - height) / 2;
                    }
                }

                Component.onCompleted: {
                    for (const s of Quickshell.screens) {
                        contentWidth = Math.max(contentWidth, s.x + s.width);
                        contentHeight = Math.max(contentHeight, s.y + s.height) / 2;
                    }
                }
            }
        }
    }

    component Properties: GroupContainer {
        label: "Properties"

        Flickable {
            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }
            height: page.height * 0.4
            clip: true
            contentHeight: innerCol.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: innerCol
                clip: true
                width: parent.width

                GroupContainer {
                    label: "Position"

                    ListView {
                        orientation: ListView.Horizontal
                        boundsBehavior: ListView.StopAtBounds
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: 50

                        model: ["left", "middle", "right"]
                        delegate: RadioDelegate {
                            required property var modelData
                            text: modelData
                            checked: page.config.position === modelData
                            onCheckedChanged: {
                                if (checked) {
                                    page.config.position = modelData;
                                }
                            }
                        }
                    }
                }

                GroupContainer {
                    label: "Direction"

                    Toggle {
                        text: !checked ? qsTr("Bottom To Top") : qsTr("Top To Bottom")
                        checked: page.config.reverse
                        onClicked: {
                            page.config.reverse = checked;
                        }
                    }
                }

                GroupContainer {
                    label: "Size"

                    ListView {
                        orientation: ListView.Horizontal
                        boundsBehavior: ListView.StopAtBounds
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: 50

                        model: ["small", "medium", "large", "custom"]
                        delegate: RadioDelegate {
                            required property var modelData
                            text: modelData
                            checked: page.config.sizing === modelData
                            onCheckedChanged: {
                                if (checked) {
                                    page.config.sizing = modelData;
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        visible: page.config.sizing === "custom"
                        Layout.fillWidth: true

                        Column {
                            spacing: 10

                            Label {
                                text: "Width"
                                font.pixelSize: 14
                            }

                            SpinBox {
                                width: 100
                                value: page.config.width
                                onValueChanged: {
                                    page.config.width = value;
                                }
                            }
                        }

                        Column {
                            spacing: 10

                            Label {
                                text: "Height"
                                font.pixelSize: 14
                            }

                            SpinBox {
                                width: 100
                                value: page.config.height
                                onValueChanged: {
                                    page.config.height = value;
                                }
                            }
                        }
                    }
                }

                GroupContainer {
                    label: "Rounding"

                    GridLayout {
                        columns: 2
                        // Radius
                        Repeater {
                            model: [
                                {
                                    label: "Top Left",
                                    prop: "topLeft"
                                },
                                {
                                    label: "Top Right",
                                    prop: "topRight"
                                },
                                {
                                    label: "Bottom Left",
                                    prop: "bottomLeft"
                                },
                                {
                                    label: "Bottom Right",
                                    prop: "bottomRight"
                                },
                            ]
                            delegate: Column {
                                id: radii
                                required property var modelData
                                width: parent.width / 2

                                Label {
                                    text: radii.modelData.label
                                }

                                SpinBox {
                                    width: 100
                                    value: page.previewStyle.background.rounding[radii.modelData.prop]
                                    onValueChanged: page.previewStyle.background.rounding[radii.modelData.prop] = value
                                }
                            }
                        }
                    }
                }

                GroupContainer {
                    label: "Duration"

                    SpinBox {
                        width: 100
                        value: page.config.duration
                        onValueChanged: {
                            page.config.duration = value;
                        }
                    }
                }
            }
        }
    }
}
