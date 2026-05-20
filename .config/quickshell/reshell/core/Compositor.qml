pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: config

    property var toplevels: ToplevelManager.toplevels
    property var focusedMonitor: Quickshell.screens[0].name
    property bool ready: false

    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() {
            if (ToplevelManager.activeToplevel?.screens !== undefined) {
                config.focusedMonitor = ToplevelManager.activeToplevel.screens[0].name;
            } else {
                Quickshell.screens[0].name;
            }
        }
    }
}
