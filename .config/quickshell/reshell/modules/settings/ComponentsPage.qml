pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.types
import qs.components
import qs.modules.notifications

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
                const notif = Components.config.notification;
                const style = notif.style;
                const source = exampleNotif.style;
                notif.width = exampleNotifItem.width;
                notif.height = exampleNotifItem.height;
                style.color = source.color;
                // padding
                style.padding.top = source.padding.top;
                style.padding.bottom = source.padding.bottom;
                style.padding.left = source.padding.left;
                style.padding.right = source.padding.right;
                // inset
                style.inset.top = source.inset.top;
                style.inset.bottom = source.inset.bottom;
                style.inset.left = source.inset.left;
                style.inset.right = source.inset.right;

                // Bg
                const bg = style.background;
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

            property QtObject style: Style {
                Component.onCompleted: {
                    const s = Components.config.notification.style;
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
                    text: "Replay Anim"
                    onClicked: exampleNotifItem.runAnim()
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
            text: "Direction"
            font.pixelSize: 24
        }

        Toggle {
            text: !checked ? qsTr("Bottom To Top") : qsTr("Top To Bottom")
            checked: Components.config.notification.reverse
            onClicked: {
                Components.config.notification.reverse = checked;
                Components.update();
            }
        }
    }

    GroupContainer {

        Label {
            text: "Size"
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
