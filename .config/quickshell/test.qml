import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick3D

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Greetd
import Quickshell.Services.Pipewire
import Quickshell.Wayland

import qs.assets
import qs.components
import qs.services

ShellRoot {
    id: root

    property var style: "neumorphic"

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("./settings.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
            root.style = settings.theme || "neumorphic";
            console.log("Settings loaded: ", settingsWatcher.text());
        }
        onLoadFailed: {
            console.log("Failed to load settings");
        }
    }

    FloatingWindow {
        id: floatingPanel

        color: Qt.rgba(0.33, 0.33, 0.41, 0.78)

        property bool isPortrait: screen.height > screen.width

        minimumSize: Qt.size(screen.width / 2, screen.height / 1.5)
        maximumSize: Qt.size(screen.width / 2, screen.height / 1.5)

        ColumnLayout {
            anchors.fill: parent

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: floatingPanel.isPortrait ? parent.height * 0.2 : parent.height * 0.3

                StyledRect {
                    childContainerHeight: parent.height
                    childContainerWidth: parent.width

                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        top: parent.top
                        margins: 20
                    }
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        text: "Settings"
                        font.pixelSize: 24
                        color: ColorPalette.color13
                        Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        Layout.fillWidth: true
                        Layout.margins: 20
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            text: "Rounding"
                            font.pixelSize: 18
                            color: ColorPalette.color13
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.preferredWidth: 100
                            Layout.margins: 20
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            value: 0
                            to: 100
                            live: false
                            onValueChanged: {
                                console.log("Slider moved to: " + Math.round(value));
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            text: "Padding"
                            font.pixelSize: 18
                            color: ColorPalette.color13
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.preferredWidth: 100
                            Layout.margins: 20
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            value: 0
                            to: 100
                            live: false
                            onValueChanged: {
                                console.log("Slider moved to: " + Math.round(value));
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            text: "Offset"
                            font.pixelSize: 18
                            color: ColorPalette.color13
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.preferredWidth: 100
                            Layout.margins: 20
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            value: 0
                            to: 100
                            live: false
                            onValueChanged: {
                                console.log("Slider moved to: " + Math.round(value));
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            text: "Volume"
                            font.pixelSize: 18
                            color: ColorPalette.color13
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            Layout.preferredWidth: 100
                            Layout.margins: 20
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            value: 0
                            to: 100
                            live: false
                            onValueChanged: {
                                console.log("Slider moved to: " + Math.round(value));
                            }
                        }
                    }
                }
            }
        }
    }
}
