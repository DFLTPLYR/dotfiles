import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

Pane {

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
                value: Global.general.notificationTimer
                onValueChanged: {
                    Global.general.notificationTimer = value;
                }
            }
        }

        Label {
            text: "Ui"
            font.pixelSize: 24
        }

        Spacer {}
    }
}
