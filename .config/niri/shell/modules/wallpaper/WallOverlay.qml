import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        Component.onCompleted: {}
    }
}
