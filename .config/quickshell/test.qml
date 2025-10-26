import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
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
import qs.config

ShellRoot {
    id: root

    property var style: "neumorphic"
    property real rounding: 20

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
                bgColor: "black"
                transparency: 1
                rounding: Example.mainRect.rounding
                padding: Example.mainRect.padding
                backingVisible: true
                backingRectX: Example.backingRect.x
                backingRectY: Example.backingRect.y
                backingRectOpacity: Example.backingRect.opacity
                intersectionVisible: Example.intersection.opacity > 0.1

                RowLayout {
                    spacing: 10
                    anchors.fill: parent
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: ColorPalette.color5
                        Text {
                            text: "Demo Area"
                            anchors.centerIn: parent
                            color: ColorPalette.color13
                            font.pixelSize: 20
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: ColorPalette.color5
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: ColorPalette.color5
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
                            from: 0
                            value: 0
                            to: 100
                            live: true
                            onValueChanged: {
                                Example.mainRect.rounding = Math.round(value);
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
                            id: paddingSlider
                            from: 0
                            value: 0
                            to: 100
                            live: true
                            onValueChanged: {
                                Example.mainRect.padding = Math.round(value);
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
                                to: Math.round(paddingSlider.value * 2)
                                live: true
                                onValueChanged: {
                                    Example.backingRect.x = Math.round(value);
                                    console.log("Slider moved to: " + Math.round(value));
                                }
                            }

                            Slider {
                                from: 0
                                value: 0
                                to: Math.round(paddingSlider.value * 2)
                                live: true
                                onValueChanged: {
                                    Example.backingRect.y = Math.round(value);
                                    console.log("Slider moved to: " + Math.round(value));
                                }
                            }
                        }
                    }

                    // Save shit
                    Button {
                        text: "Save Settings"
                        onClicked: {
                            Example.saveSettings();
                        }
                    }
                }
            }
        }
    }
}
