import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Greetd

import Quickshell.Io
import Quickshell.Wayland

import qs.assets
import qs.services
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: root
            required property ShellScreen modelData
            screen: modelData
            property bool isPortrait: screen.height > screen.width
            property bool isLoading: true

            anchors {
                left: true
                bottom: true
                right: true
                top: true
            }

            color: Qt.rgba(0.33, 0.33, 0.41, 0.78)
            exclusiveZone: ExclusionMode.Ignore
            aboveWindows: false

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

            // additional blur for sigma effect :D
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.33, 0.33, 0.41, 0.2)
            }

            // back shadow of the login ui
            RectangularShadow {
                anchors.fill: uiLogin
                offset.x: -10
                offset.y: -5
                radius: uiLogin.radius
                blur: 30
                spread: 10
                color: Qt.darker(uiLogin.color, 0.4)
            }

            // log in ui
            Rectangle {
                id: uiLogin
                anchors.centerIn: parent
                width: isPortrait ? screen.width / 2 : screen.width / 2
                height: isPortrait ? screen.height / 2.5 : screen.height / 2
                radius: 14
                layer.enabled: true
                color: Qt.rgba(0.72, 0.72, 0.76, 0.23)
                border.color: Qt.rgba(0.13, 0.13, 0.14, 0.31)

                // Items

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Connections {
                target: WeatherFetcher
                function onParseDone() {
                    root.isLoading = false;
                }
            }

            Component.onCompleted: {
                root.isLoading = typeof WeatherFetcher.currentCondition === 'undefined';
            }
        }
    }
}
