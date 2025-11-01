import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.assets
import qs.utils

Scope {
    id: root
    property bool isVisible: false

    GlobalShortcut {
        name: "showScreenOverLay"
        description: "Show the Custom OSD something idk still"
        onPressed: {
            root.isVisible = !root.isVisible;
            console.log("Screen Overlay Toggled: " + root.isVisible);
        }
    }

    Loader {
        id: overLayLoader
        active: root.isVisible
        sourceComponent: OverLayComponent {}
    }

    component OverLayComponent: PanelWindow {
        id: screenOSD

        color: Scripts.setOpacity(ColorPalette.background, 0.4)

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        Component.onCompleted: {
            if (this.WlrLayershell) {
                this.WlrLayershell.layer = WlrLayer.Overlay;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                this.exclusionMode = ExclusionMode.Ignore;
            }
        }
    }
}
