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

    FileView {
        id: settingsWatcher
        path: Qt.resolvedUrl("./test.json")
        watchChanges: true
        onFileChanged: settingsWatcher.reload()
        onLoaded: {
            const settings = JSON.parse(settingsWatcher.text());
        }
        onLoadFailed: root.saveSettings()
    }

    function saveSettings() {
        const settings = {};
        settingsWatcher.setText(JSON.stringify(settings, null, 2));
    }

    FloatingWindow {
        id: floatingPanel

        color: Qt.rgba(0.33, 0.33, 0.41, 0.78)

        property bool isPortrait: screen.height > screen.width

        minimumSize: Qt.size(screen.width / 2, screen.height / 1.5)
        maximumSize: Qt.size(screen.width / 2, screen.height / 1.5)

        StyledContainer {
            id: testing
            Component.onCompleted: {
                for (let key in testing) {
                    console.log(key, testing[key]);
                }
            }
        }
    }
}
