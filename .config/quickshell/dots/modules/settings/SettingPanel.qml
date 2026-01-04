import QtQuick
import QtQuick.Layouts

import Quickshell

Scope {

    LazyLoader {
        id: settingsLoader
        component: FloatingWindow {
            title: "SettingsPanel"
            readonly property size panelSize: Qt.size(600, 800)
            minimumSize: panelSize
            maximumSize: panelSize
            color: Qt.rgba(0, 0, 0, 0.8)
        }
    }
}
