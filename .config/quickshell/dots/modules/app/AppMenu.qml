import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.components
import qs.config

Scope {
    LazyLoader {
        id: appMenuLoader
        property bool shouldBeVisible: false
        component: PanelWrapper {
            id: screenPanel
            color: Qt.rgba(0, 0, 0, 0.5)
            shouldBeVisible: appMenuLoader.shouldBeVisible

            anchors {
                left: true
                right: true
                top: true
                bottom: true
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
    Connections {
        target: Config
        function onOpenAppLauncherChanged() {
            appMenuLoader.active = !appMenuLoader.active;
            appMenuLoader.shouldBeVisible = !appMenuLoader.shouldBeVisible;
        }
    }
}
