import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.components
import qs.utils
import qs.config

Variants {
    model: Quickshell.screens
    PanelWindow {
        id: overlay
        property var modelData
        screen: modelData
        color: "transparent"

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        Rectangle {
            id: movableRect
            width: 200
            height: 200
            x: 0
            y: 0
            color: Scripts.setOpacity(Color.background, 0.5)
            MouseArea {
                anchors.fill: parent
                drag.target: parent
            }
        }

        Component.onCompleted: {
            if (this.WlrLayershell) {
                this.WlrLayershell.layer = WlrLayer.Background;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
                this.exclusionMode = ExclusionMode.Ignore;
            }
        }
    }
}
