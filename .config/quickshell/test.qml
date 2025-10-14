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
            // exclusiveZone: ExclusionMode.Ignore
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




            Connections {
                function onParseDone() {
                    root.isLoading = false;
                }

                target: WeatherFetcher
            }

        }

    }

}
