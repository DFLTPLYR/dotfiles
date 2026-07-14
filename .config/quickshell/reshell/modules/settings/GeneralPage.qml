pragma ComponentBehavior: Bound

import Quickshell

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

Page {
    property var screen

    GreeterSection {}

    DisplayTemp {}

    ColorSchemeSection {}

    component GreeterSection: GroupContainer {
        Label {
            text: "Greeter"
            font.pixelSize: 32
            color: Colors.theme.primary
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
    }

    component DisplayTemp: GroupContainer {
        Label {
            text: "Screen Temp"
            font.pixelSize: 32
            Layout.fillWidth: true
        }

        Button {
            text: "Increase"
            onClicked: {
                Quickshell.execDetached(["busctl", "--user", "call", "--", "rs.wl-gammarelay", "/", "rs.wl.gammarelay", "UpdateTemperature", "n", "500"]);
            }
        }

        Button {
            text: "Decrease"
            onClicked: {
                Quickshell.execDetached(["busctl", "--user", "call", "--", "rs.wl-gammarelay", "/", "rs.wl.gammarelay", "UpdateTemperature", "n", "-500"]);
            }
        }
    }

    component ColorSchemeSection: GroupContainer {
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
            clip: true
            spacing: 10

            anchors {
                left: parent.left
                right: parent.right
            }
            height: 150
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
                        const cTheme = darkmodeToggle.checked ? json.dark : json.light;
                        if (Global.matugen.color !== cTheme) {
                            Global.matugen.color = cTheme;
                        }
                    }
                }
            }
        }
    }
}
