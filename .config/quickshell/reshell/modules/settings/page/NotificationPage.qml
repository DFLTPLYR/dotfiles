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

    grid.data: [
        Button {
            text: "Set"
            visible: Quickshell.screens.length >= 1
            onClicked: popup.opened ? popup.close() : popup.open()
        },
        Button {
            text: "Apply"
        }
    ]

    // to be added
    // PopupModal {
    //     id: popup
    //     width: page.width / 8
    //     height: page.height / 8
    //     x: (page.width / 2) - (width / 2)
    //     y: (page.height / 2) - (height / 2)
    //
    //     Toggle {
    //         text: "Screen 1"
    //     }
    // }

    GroupContainer {
        label: "Notification Section"

        Rectangle {
            id: exampleNotif
            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }
            height: exampleNotifItem.height + parent.padding

            property QtObject style: Style {
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

            property var example: {
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

            color: Colors.theme.on_surface
            radius: 5

            NotificationItem {
                id: exampleNotifItem
                ma.enabled: false
                property var style: exampleNotif.style
                anchors.centerIn: parent
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

                modelData: exampleNotif.example
            }

            Row {
                anchors {
                    rightMargin: 5
                    bottomMargin: 5
                    bottom: parent.bottom
                    right: parent.right
                }

                Button {
                    text: "Replay Anim"
                    onClicked: exampleNotifItem.runAnim()
                }
            }
        }
    }

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
                        exampleNotifItem.width = value;
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
                        exampleNotifItem.height = value;
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
                        value: exampleNotif.style.background.rounding[radii.modelData.prop]
                        onValueChanged: exampleNotif.style.background.rounding[radii.modelData.prop] = value
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
