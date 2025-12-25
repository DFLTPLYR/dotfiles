import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

Scope {
    PanelWindow {
        screen: Quickshell.screens.find(s => s.name === Config.focusedMonitor?.name) ?? null
        implicitWidth: 0
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        Component.onCompleted: {
            if (this.WlrLayershell) {
                this.exclusionMode = ExclusionMode.Normal;
                this.WlrLayershell.layer = WlrLayer.Top;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
            }
        }
    }
}
