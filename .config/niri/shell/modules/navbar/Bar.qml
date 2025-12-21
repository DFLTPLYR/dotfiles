import QtQuick
import Quickshell

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen screen
        anchors {
            left: true
            bottom: true
            right: true
        }
    }
}
