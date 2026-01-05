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
            color: "transparent"
            shouldBeVisible: appMenuLoader.shouldBeVisible

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)
                opacity: screenPanel.animProgress
                Behavior on height {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
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
    Connections {
        target: Config
        function onOpenAppLauncherChanged() {
            if (!appMenuLoader.active) {
                appMenuLoader.active = true;
                appMenuLoader.shouldBeVisible = !appMenuLoader.shouldBeVisible;
            } else {
                appMenuLoader.shouldBeVisible = !appMenuLoader.shouldBeVisible;
            }
        }
    }
}
