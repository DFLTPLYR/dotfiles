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
                text: "Color Scheme"
                font.pixelSize: 32
                Layout.fillWidth: true
            }

            Toggle {
                id: darkmodeToggle
                text: "Dark mode"
                checkable: true
                checked: Global.general.darkmode
                onCheckedChanged: {
                    Global.general.darkmode = checked;
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                clip: true
                model: Colors.themes
                orientation: ListView.Horizontal
                spacing: 10
                delegate: Pane {
                    id: theme
                    required property var model
                    property var dark: model.dark
                    property var light: model.light

                    bg.color: Colors.setOpacity(Colors.theme.on_surface, 1)
                    bg.radius: 12
                    height: ListView.view.height
                    width: height

                    ColumnLayout {
                        anchors.fill: parent

                        Label {
                            id: label
                            Layout.fillWidth: true
                            text: model.name
                            color: Colors.theme.surface
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Grid {
                            id: grid
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            columns: 2
                            spacing: 0
                            Repeater {
                                model: ["primary", "secondary", "tertiary", "surface"]
                                delegate: Item {
                                    required property string modelData
                                    width: grid.width / 2
                                    height: grid.height / 2

                                    Pane {
                                        anchors.centerIn: parent
                                        width: Math.min(parent.width, parent.height) * 0.8
                                        height: width
                                        bg.radius: height / 2
                                        bg.color: darkmodeToggle.checked ? theme.dark[modelData] : theme.light[modelData]
                                    }
                                    Component.onCompleted: {
                                        print(theme, modelData);
                                    }
                                }
                            }
                        }
                    }
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
                    "appIcon": "firefox",
                    "appName": "firefox",
                    "body": "This is the text body of the notification. \nPretty cool, huh?",
                    "image": "",
                    "summary": "Notification Example",
                    "time": 1777989368250,
                    "urgency": "1"
                }

                property QtObject style: QtObject {
                    property color color: Colors.setOpacity(Colors.theme.surface, 0.5)
                    property Direction padding: Direction {}
                    property Direction inset: Direction {}

                    property QtObject background: QtObject {
                        property Corner rounding: Corner {}
                        property Direction margins: Direction {}
                    }
                }

                Layout.fillWidth: true
                Layout.preferredHeight: exampleNotifItem.height + 100
                color: Colors.theme.on_surface
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
        color: Colors.theme.tertiary
    }
}
