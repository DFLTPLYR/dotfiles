import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Greetd

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

            anchors {
                left: true
                bottom: true
                right: true
                top: true
            }

            color: Qt.rgba(0.36, 0.36, 0.59, 0.4)
            exclusiveZone: ExclusionMode.Ignore
            aboveWindows: false

            // Window panel per screen
            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: WallpaperStore.currentWallpapers[screen.name] ?? null
                cache: true
                asynchronous: true
                smooth: true
                visible: false
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
                width: isPortrait ? screen.width / 1.5 : screen.width / 2
                height: isPortrait ? screen.height / 2.5 : screen.height / 2
                radius: 14
                layer.enabled: true
                color: Qt.rgba(0.72, 0.72, 0.76, 0.23)
                border.color: Qt.rgba(0.13, 0.13, 0.14, 0.31)
            }

            // widget
            Item {
                width: 300
                height: Math.min(200, root.isPortrait ? root.height / 4 : root.height / 2)

                // Background
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 10
                    radius: 10
                    color: Qt.rgba(0.72, 0.72, 0.76, 0.23)
                    border.color: Qt.rgba(0.13, 0.13, 0.14, 0.31)
                }
            }
        }
    }
}
