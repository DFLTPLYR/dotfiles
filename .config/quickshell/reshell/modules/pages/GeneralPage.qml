pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.types
import qs.components

Pane {
    id: pane
    property var screen

    Flickable {
        anchors.fill: parent
        interactive: true
        contentWidth: column.width
        contentHeight: column.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: column
            width: pane.width

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
                property var config: Components.config.notification
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
                    "image": "",
                    "summary": "Notification Example",
                    "time": 1777989368250,
                    "urgency": "1"
                }

                property QtObject style: QtObject {
                    property color color: Colors.setOpacity(Colors.color.background, 0.5)
                    property Direction padding: Direction {}
                    property Direction inset: Direction {}

                    property QtObject background: QtObject {
                        property Corner rounding: Corner {}
                        property Direction margins: Direction {}
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: exampleNotifItem.height + 100
                color: Colors.setOpacity(Colors.color.background, 0.5)
                radius: 5

                NotificationItem {
                    id: exampleNotifItem
                    style: exampleNotif.style
                    anchors.centerIn: parent
                    width: exampleNotif.config.height
                    height: exampleNotif.config.width
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

            Label {
                text: "Rounding"
                font.pixelSize: 24
            }

            RowLayout {
                Column {
                    width: parent.width / 2
                    Label {
                        text: "Top Left"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                    }
                }
                Column {
                    width: parent.width / 2
                    Label {
                        text: "Top Right"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                    }
                }
                Column {
                    width: parent.width / 2
                    Label {
                        text: "Bottom Left"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                    }
                }
                Column {
                    width: parent.width / 2
                    Label {
                        text: "Bottom Right"
                    }
                    SpinBox {
                        width: 100
                        height: 20
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

            Spacer {}
        }
    }
    component Spacer: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 2
        color: Colors.color.tertiary
    }
}
