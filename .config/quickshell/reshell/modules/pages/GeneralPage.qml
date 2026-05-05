pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

Pane {
    id: pane
    property var screen
    property var notification: Global.general.notification

    component Spacer: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 2
        color: Colors.color.tertiary
    }

    ColumnLayout {
        width: parent.width
        height: contentHeight

        Label {
            text: "Greeter"
            font.pixelSize: 32
            Layout.fillWidth: true
        }

        Toggle {
            property bool greeter: Global.general.greeter
            text: greeter ? "Enable" : "Disable"
            checked: greeter
            onCheckedChanged: {
                Global.general.greeter = checked;
                Global.save();
            }
        }

        Spacer {}

        Label {
            text: "Notification Section"
            font.pixelSize: 32
            Layout.fillWidth: true
        }

        Rectangle {
            id: exampleNotif
            property var example: {
                "notificationId": 69,
                "actions": [
                    {
                        "identifier": "default",
                        "text": "Activate"
                    }
                ],
                "appIcon": "zen-browser",
                "appName": "Zen",
                "body": "This is the text body of the notification. \nPretty cool, huh?",
                "image": "image://qsimage/6/1",
                "summary": "Notification Example",
                "time": 1777989368250,
                "urgency": "1"
            }

            Layout.fillWidth: true
            Layout.preferredHeight: exampleNotifItem.height + 100
            color: Colors.setOpacity(Colors.color.background, 0.5)
            radius: 5

            NotificationItem {
                id: exampleNotifItem
                anchors.centerIn: parent
                width: pane.notification.height
                height: pane.notification.width
                modelData: exampleNotif.example
                Component.onCompleted: this.ma.enabled = false
            }
        }

        Label {
            text: "Ui"
            font.pixelSize: 24
        }

        Row {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Width"
                font.pixelSize: 14
            }

            SpinBox {
                width: 100
                value: pane.notification.width
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
                value: pane.notification.height
                onValueChanged: {
                    exampleNotifItem.height = value;
                }
            }
        }

        Label {
            text: "Rounding"
            font.pixelSize: 24
        }

        RowLayout {

            Column {
                width: rounding.width / 2
                Label {
                    text: "Top Left"
                }
                SpinBox {
                    width: 100
                    height: 20
                    onValueChanged: rounding.rounding.topLeft = value
                }
            }
            Column {
                width: rounding.width / 2
                Label {
                    text: "Top Right"
                }
                SpinBox {
                    width: 100
                    height: 20
                    onValueChanged: rounding.rounding.topRight = value
                }
            }
            Column {
                width: rounding.width / 2
                Label {
                    text: "Bottom Left"
                }
                SpinBox {
                    width: 100
                    height: 20
                    onValueChanged: rounding.rounding.bottomLeft = value
                }
            }
            Column {
                width: rounding.width / 2
                Label {
                    text: "Bottom Right"
                }
                SpinBox {
                    width: 100
                    height: 20
                    onValueChanged: exampleNotifItem.rounding.bottomRight = value
                }
            }
        }

        Row {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Timer"
                font.pixelSize: 14
            }

            SpinBox {
                width: 100
                value: pane.notification.duration
                onValueChanged: {
                    pane.notification.duration = value;
                }
            }
        }

        Spacer {}
    }
}
