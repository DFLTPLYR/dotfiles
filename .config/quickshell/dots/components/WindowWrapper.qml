import QtQuick
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen modelData
        screen: modelData
        color: "transparent"
        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        Component.onCompleted: {
            if (this.WlrLayershell) {
                this.exclusionMode = ExclusionMode.Ignore;
                this.WlrLayershell.layer = WlrLayer.Background;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
            }
        }
    }
}
