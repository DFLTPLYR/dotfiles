import QtQuick
import Quickshell
import Quickshell.Io

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root
        required property ShellScreen modelData
        screen: modelData
        visible: false
    }
}
