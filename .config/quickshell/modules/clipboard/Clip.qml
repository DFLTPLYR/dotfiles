import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.config
import qs.assets
import qs.utils
import qs.components

Scope {
    id: root
    property bool isVisible: false
    signal toggle

    GlobalShortcut {
        id: cancelKeybind
        name: "showClipBoard"
        description: "Show Clipboard history"

        onPressed: {
            Qt.callLater(() => {
                root.isVisible = true;
                root.toggle();
            });
        }
    }

    LazyLoader {
        active: root.isVisible
        component: PanelWrapper {
            id: panelWrapper
            implicitWidth: 0
            color: isVisible ? Scripts.setOpacity(Color.background, 0.4) : "transparent"

            anchors {
                top: true
                bottom: true
                right: true
                left: true
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Connections {
                target: root
                function onToggle() {
                    panelWrapper.shouldBeVisible = !panelWrapper.shouldBeVisible;
                }
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
}
