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
        minimumSize: Qt.size(800, 600)
        maximumSize: Qt.size(800, 600)
        color: Qt.rgba(0.33, 0.33, 0.41, 0.78)

        ColumnLayout {
            anchors.fill: parent

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                StyledRect {
                    childContainerHeight: parent.height
                    childContainerWidth: parent.width
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        top: parent.top
                        margins: 10
                    }
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    // Variants {
    //     model: Quickshell.screens
    //
    //     delegate: PanelWindow {
    //
    //         required property ShellScreen modelData
    //         property bool isPortrait: screen.height > screen.width
    //         property bool isLoading: true
    //
    //         screen: modelData
    //         color: Qt.rgba(0.33, 0.33, 0.41, 0.78)
    //         exclusiveZone: ExclusionMode.Ignore
    //         aboveWindows: false
    //
    //         Rectangle {
    //             anchors.fill: parent
    //             color: "transparent"
    //
    //         }
    //     }
    // }
}
