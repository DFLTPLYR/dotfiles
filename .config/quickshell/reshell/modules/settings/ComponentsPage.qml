pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import qs.components
import qs.types
import qs.core

Page {

    GroupContainer {
        Label {
            text: "Notification Section"
            font.pixelSize: 32
        }

        Rectangle {
            id: exampleNotif
            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }
            height: exampleNotifItem.height + parent.padding

            function applyStyle() {
                const target = Components.config.notification.style;
                const source = exampleNotif.style;
                target.color = source.color;
                // padding
                target.padding.top = source.padding.top;
                target.padding.bottom = source.padding.bottom;
                target.padding.left = source.padding.left;
                target.padding.right = source.padding.right;
                // inset
                target.inset.top = source.inset.top;
                target.inset.bottom = source.inset.bottom;
                target.inset.left = source.inset.left;
                target.inset.right = source.inset.right;

                // Bg
                const bg = target.background;
                bg.rounding.topLeft = source.background.rounding.topLeft;
                bg.rounding.topRight = source.background.rounding.topRight;
                bg.rounding.bottomLeft = source.background.rounding.bottomLeft;
                bg.rounding.bottomRight = source.background.rounding.bottomRight;

                bg.margins.top = source.background.margins.top;
                bg.margins.bottom = source.background.margins.bottom;
                bg.margins.left = source.background.margins.left;
                bg.margins.right = source.background.margins.right;

                Components.update();
            }

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

            color: Colors.theme.on_surface
            radius: 5

            NotificationItem {
                id: exampleNotifItem
                ma.enabled: false
                property var style: exampleNotif.style
                anchors.centerIn: parent
                width: exampleNotif.config.width
                height: exampleNotif.config.height

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
                    onClicked: exampleNotif.applyStyle()
                }
            }
        }
    }

    GroupContainer {
        Label {
            text: "Notification Dimensions"
            font.pixelSize: 24
        }

        GroupSpacer {}

        ColumnLayout {
            Layout.fillWidth: true

            Column {
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

            Column {
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
    }

    GroupContainer {
        Label {
            text: "Rounding"
            font.pixelSize: 24
        }

        GroupSpacer {}

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

        Label {
            text: "Duration"
            font.pixelSize: 24
        }

        GroupSpacer {}

        SpinBox {
            width: 100
            value: exampleNotif.config.duration
            onValueChanged: {
                exampleNotif.config.duration = value;
            }
        }
    }
}
