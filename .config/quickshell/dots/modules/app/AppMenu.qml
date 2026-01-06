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

            PopupWindow {
                anchor.window: screenPanel
                anchor.rect.x: parentWindow.width / 2 - width / 2
                anchor.rect.y: (parentWindow.screen.height / 2 - height / 2)
                implicitWidth: parentWindow.screen.width * 0.5
                implicitHeight: parentWindow.screen.height * 0.6
                color: "transparent"
                visible: screenPanel.internalVisible

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
                if (!Config.openAppLauncher)
                    return;
                appMenuLoader.shouldBeVisible = !appMenuLoader.shouldBeVisible;
            }
        }
    }
}
