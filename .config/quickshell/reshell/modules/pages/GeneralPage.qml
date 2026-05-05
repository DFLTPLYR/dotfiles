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

        Label {
            text: "Ui"
            font.pixelSize: 24
        }

        Label {
            text: "Position"
            font.pixelSize: 14
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
                    pane.notification.width = value;
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
                    pane.notification.height = value;
                }
            }
        }
        Spacer {}
    }
}
