import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Scope {
    id: root
    property bool isVisible: false

    GlobalShortcut {
        name: "showScreenOverLay"
        onPressed: {
            root.isVisible = !root.isVisible;
        }
    }

    Loader {
        id: overLayLoader
        active: root.isVisible
        sourceComponent: OverLayComponent {}
    }

    component OverLayComponent: PanelWindow {
        id: screenOSD
        anchors {
            left: true
            bottom: true
            right: true
            top: true
        }
        Component.onCompleted: {
            if (this.WlrLayershell != null) {
                this.WlrLayershell.layer = WlrLayer.Overlay;
                this.wlrLayershell.keyboardFocus = KeyboardFocus.Exclusive;
            }
        }
    }
}
