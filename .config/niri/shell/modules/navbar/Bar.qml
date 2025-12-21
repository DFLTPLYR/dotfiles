import QtQuick
import Quickshell

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen modelData
        screen: modelData
        anchors {
            top: true
            left: true
            right: true
        }
        color: "transparent"
        implicitHeight: 50
    }
}
