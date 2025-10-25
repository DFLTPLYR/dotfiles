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
import qs.utils

ShellRoot {
    id: root

    property var style: "neumorphic"
    property real rounding: 20

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
                id: layoutHandler
                property bool enabledBackingRect: true
                Layout.fillWidth: true
                Layout.preferredHeight: floatingPanel.isPortrait ? parent.height * 0.2 : parent.height * 0.3
                Rectangle {
                    id: rect
                    height: parent.height
                    width: parent.width
                    color: Scripts.setOpacity(ColorPalette.background, 1)
                    anchors.margins: 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
                Rectangle {
                    id: backgroundRect
                    visible: layoutHandler.enabledBackingRect
                    height: rect.height
                    width: rect.width
                    radius: rect.radius
                    color: Scripts.setOpacity(ColorPalette.background, 1)
                }
                Rectangle {
                    id: intersectionRect

                    x: Math.max(rect.x, backgroundRect.x)
                    y: Math.max(rect.y, backgroundRect.y)
                    width: Math.max(0, Math.min(rect.x + rect.width, backgroundRect.x + backgroundRect.width) - Math.max(rect.x, backgroundRect.x))
                    height: Math.max(0, Math.min(rect.y + rect.height, backgroundRect.y + backgroundRect.height) - Math.max(rect.y, backgroundRect.y))
                    color: "green"
                    opacity: 0.7
                    visible: layoutHandler.enabledBackingRect && width > 0 && height > 0

                    border.color: "black"
                    border.width: 2
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
                            from: 0
                            value: 0
                            to: 100
                            live: true
                            onValueChanged: {
                                rect.radius = Math.round(value);
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
                            from: 0
                            value: 0
                            to: 100
                            live: true
                            onValueChanged: {
                                rect.anchors.margins = Math.round(value);
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
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Slider {
                                from: 0
                                value: 0
                                to: 100
                                live: true
                                onValueChanged: {
                                    backgroundRect.x = Math.round(value);
                                    console.log("Slider moved to: " + Math.round(value));
                                }
                            }
                            Slider {
                                from: 0
                                value: 0
                                to: 100
                                live: true
                                onValueChanged: {
                                    backgroundRect.y = Math.round(value);
                                    console.log("Slider moved to: " + Math.round(value));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
