import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen modelData
        screen: modelData

        color: Qt.rgba(0, 0, 0, 0.5)

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape) {
                    Config.openSessionMenu = false;
                }
            }
        }
        Component.onCompleted: {
            if (this.WlrLayershell) {
                this.exclusionMode = ExclusionMode.Ignore;
                this.WlrLayershell.layer = WlrLayer.Top;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
            }
        }
    }
}
