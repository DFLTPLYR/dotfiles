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

            Themes {}

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

    component Themes: ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        clip: true
        spacing: 10
        orientation: ListView.Horizontal
        boundsBehavior: ListView.StopAtBounds
        model: Colors.themes

        delegate: Item {
            id: theme
            required property var model
            property var dark: model.dark
            property var light: model.light
            readonly property bool current: Global.general.theme === model.name
            height: ListView.view.height
            width: height

            ColumnLayout {
                anchors.fill: parent

                Label {
                    id: label
                    Layout.fillWidth: true
                    text: theme.model.name
                    color: theme.current ? Colors.theme.primary : Colors.theme.on_surface

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Pane {
                        anchors.centerIn: parent
                        width: parent.height
                        height: parent.height
                        bg.color: theme.current ? Colors.theme.on_surface : Colors.theme.on_surface_variant
                        bg.radius: (ma.containsMouse || theme.current) ? 12 : 6

                        Behavior on bg.color {
                            ColorAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }
                        Behavior on bg.radius {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.InOutQuad
                            }
                        }

                        Grid {
                            id: grid
                            anchors.fill: parent
                            columns: 2
                            spacing: 0

                            Repeater {
                                model: ["primary", "secondary", "tertiary", "surface"]
                                delegate: Item {
                                    required property string modelData
                                    width: grid.width / 2
                                    height: grid.height / 2

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Math.min(parent.width, parent.height) * 0.9
                                        height: width
                                        radius: (ma.containsMouse || theme.current) ? height * 1 : height * 0.1
                                        color: darkmodeToggle.checked ? theme.dark[modelData] : theme.light[modelData]

                                        Behavior on radius {
                                            NumberAnimation {
                                                duration: 300
                                                easing.type: Easing.InOutQuad
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    Global.general.theme = theme.model.name;
                    const colorscheme = Colors.themes.find(s => s.name === theme.model.name);
                    if (!colorscheme)
                        return;
                    const text = colorscheme.file.text();
                    const json = JSON.parse(text);
                    if (!Global.matugen.running) {
                        Global.matugen.color = darkmodeToggle.checked ? json.dark : json.light;
                    }
                }
            }
        }
    }
}
