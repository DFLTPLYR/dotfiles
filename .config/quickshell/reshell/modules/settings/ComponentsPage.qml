pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import qs.components
import qs.types
import qs.core

Pane {
    id: pane
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        width: pane.width

        Label {
            text: "Notification Section"
            font.pixelSize: 32
            Layout.fillWidth: true
        }

        Rectangle {
            id: exampleNotif
            property var config: Components.config.notification
            property QtObject style: QtObject {
                property color color: Colors.setOpacity(Colors.theme.surface, 0.5)
                property Direction padding: Direction {}
                property Direction inset: Direction {}

                property QtObject background: QtObject {
                    property Corner rounding: Corner {}
                    property Direction margins: Direction {}
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

            Layout.fillWidth: true
            Layout.preferredHeight: exampleNotifItem.height + 100
            color: Colors.theme.on_surface
            radius: 5

            NotificationItem {
                id: exampleNotifItem
                ma.enabled: false
                property var style: exampleNotif.style
                anchors.centerIn: parent
                width: exampleNotif.config.height
                height: exampleNotif.config.width

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
                    text: "Cancel"
                }

                Button {
                    text: "Save"
                }
            }
        }

        Label {
            text: "Notification Dimensions"
            font.pixelSize: 24
        }

        ColumnLayout {
            Layout.fillWidth: true

            Row {
                spacing: 10

                Label {
                    text: "Width"
                    font.pixelSize: 14
                }

                SpinBox {
                    width: 100
                    value: exampleNotif.config.width
                    onValueChanged: {
                        exampleNotifItem.width = value;
                    }
                }
            }

            Row {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: "Height"
                    font.pixelSize: 14
                }

                SpinBox {
                    width: 100
                    value: exampleNotif.config.height
                    onValueChanged: {
                        exampleNotifItem.height = value;
                    }
                }
            }
        }

        Label {
            text: "Rounding"
            font.pixelSize: 24
        }

        RowLayout {
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
                        height: 20
                        value: exampleNotif.style.background.rounding[radii.modelData.prop]
                        onValueChanged: exampleNotif.style.background.rounding[radii.modelData.prop] = value
                    }
                }
            }
        }

        Row {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Duration"
                font.pixelSize: 14
            }

            SpinBox {
                width: 100
                value: exampleNotif.config.duration
                onValueChanged: {
                    exampleNotif.config.duration = value;
                }
            }
        }
    }
}
