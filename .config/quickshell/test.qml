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
import qs.services

ShellRoot {
    Variants {
        // back shadow of the login ui

        model: Quickshell.screens

        delegate: PanelWindow {
            id: root

            required property ShellScreen modelData
            property bool isPortrait: screen.height > screen.width
            property bool isLoading: true

            screen: modelData
            color: Qt.rgba(0.33, 0.33, 0.41, 0.78)
            exclusiveZone: ExclusionMode.Ignore
            aboveWindows: false
            Component.onCompleted: {
                root.isLoading = typeof WeatherFetcher.currentCondition === 'undefined';
            }

            anchors {
                left: true
                bottom: true
                right: true
                top: true
            }

            // blur per screen
            GaussianBlur {
                anchors.fill: parent
                radius: 20
                samples: 20

                source: Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: WallpaperStore.currentWallpapers[screen.name] ?? null
                    cache: true
                    asynchronous: true
                    smooth: true
                }

            }

            Item {
                layer.enabled: true
                width: parent.width
                implicitHeight: 120

                anchors {
                    topMargin: 10
                    leftMargin: 10
                    rightMargin: 10
                    bottomMargin: 10
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                Rectangle {
                    width: parent.width - 10
                    height: 30
                    radius: 2
                }

                Rectangle {
                    x: 5
                    y: 5
                    radius: 2
                    width: parent.width - 10
                    height: 30
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 4

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Row {
                                spacing: 2
                                anchors.fill: parent

                                Repeater {
                                    model: Hyprland.workspaces

                                    delegate: Item {
                                        layer.enabled: true
                                        width: parent.height
                                        height: parent.height

                                        Rectangle {
                                            width: parent.height
                                            height: parent.height
                                            color: (modelData.active && modelData.focused) ? ColorPalette.color2 : ColorPalette.color14
                                            radius: 4
                                            border.width: (modelData.active && modelData.focused) ? 1 : 0.5
                                            border.color: (modelData.active && modelData.focused) ? ColorPalette.color14 : ColorPalette.color2

                                            Text {
                                                color: (modelData.active && modelData.focused) ? ColorPalette.color14 : ColorPalette.color2
                                                anchors.centerIn: parent
                                                text: modelData.id >= -1 ? modelData.id : "S"
                                                font.family: FontProvider.fontSometypeMono
                                                font.pixelSize: {
                                                    var minSize = 10;
                                                    return Math.max(minSize, Math.min(parent.height, parent.width) * 0.7);
                                                }
                                            }

                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                modelData.active();
                                            }
                                        }

                                    }

                                }

                            }

                        }

                        Item {
                            Layout.preferredWidth: Math.round(parent.width * 0.7)
                            Layout.fillHeight: true
                            layer.enabled: true

                            Text {
                                color: ColorPalette.color2
                                font.family: FontProvider.fontMaterialRounded
                                text: `${TimeService.hoursPadded} : ${TimeService.minutesPadded}... ${TimeService.ampm}`
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                                font.bold: true
                                font.pixelSize: {
                                    var minSize = 10;
                                    return Math.max(minSize, Math.min(parent.height, parent.width) * 0.2);
                                }
                            }

                            Behavior on opacity {
                                AnimationProvider.NumberAnim {
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Rectangle {
                                anchors.fill: parent
                                color: "gray"
                            }

                        }

                    }

                }

            }

            Connections {
                function onParseDone() {
                    root.isLoading = false;
                }

                target: WeatherFetcher
            }

        }

    }

}
