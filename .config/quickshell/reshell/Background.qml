import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        screen: modelData

        color: "transparent"

        implicitHeight: screen.height
        implicitWidth: screen.width

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: `Background-${screen.name}`
    }
}
