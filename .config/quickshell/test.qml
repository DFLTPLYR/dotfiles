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

    QtObject {
        id: rectprops
        property int radius: 0
        property bool backingrectenabled: false
        property bool showintersection: false
        property int backingrectx: 0
        property int backingrecty: 0
        property int padding: 0
        property real bgOpacity: 1.0
    }

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

            StyledRectangle {
                id: rect
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                bgColor: ColorPalette.background
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
                                rect.rounding = Math.round(value);
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
                                rect.padding = Math.round(value);
                                console.log("Slider moved to: " + Math.round(value));
                            }
                        }
                    }

                    // Backing Rectangle Position
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        CheckBox {
                            text: qsTr("Enable Backing Rect")
                            Layout.margins: 20

                            onPressed: {
                                rect.backingVisible = this.checked;
                            }
                        }
                        CheckBox {
                            text: qsTr("Second")
                            Layout.margins: 20
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            text: "Position"
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
                                    rect.backingRectX = Math.round(value);
                                    console.log("Slider moved to: " + Math.round(value));
                                }
                            }

                            Slider {
                                from: 0
                                value: 0
                                to: 100
                                live: true
                                onValueChanged: {
                                    rect.backingRectY = Math.round(value);
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
