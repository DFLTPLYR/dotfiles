import QtQuick

import Quickshell
import Quickshell.Io

import qs.config
import qs.components

Scope {
    id: root
    property bool isVisible: false
    signal toggle

    LazyLoader {
        id: panelLoader
        active: root.isVisible
        component: PanelWrapper {
            id: sidebarRoot
            implicitWidth: 0
            color: isVisible ? Qt.rgba(0, 0, 0, 0.5) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            anchors {
                top: true
                bottom: true
                right: true
                left: true
            }

            // Contents
            StyledRect {
                width: 500 * sidebarRoot.animProgress
                height: 500 * sidebarRoot.animProgress
                fill: true
                x: Math.round(screen.width / 2 - width / 2)
                y: Math.round(screen.height / 2 - height / 2)
                color: Qt.rgba(0, 0, 0, 0.5)
                borderWidth: 2
                borderColor: "green"
            }

            Connections {
                target: root
                function onToggle() {
                    sidebarRoot.shouldBeVisible = !sidebarRoot.shouldBeVisible;
                }
            }
            // set up
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
        function onOpenWallpaperPickerChanged() {
            root.isVisible = true;
            root.toggle();
        }
    }
}

// import qs.config
//
// Variants {
//     model: Quickshell.screens
//     delegate: PanelWindow {
//         id: root
//         required property ShellScreen modelData
//         screen: modelData
//         visible: Config.openWallpaperPicker && Config.focusedMonitor.name === screen.name
//
//         color: Qt.rgba(0.1, 0.1, 0.1, 0.5)
//
//         anchors {
//             top: true
//             bottom: true
//             right: true
//             left: true
//         }
//
//         Component.onCompleted: {
//             if (this.WlrLayershell) {
//                 this.WlrLayershell.layer = WlrLayer.Overlay;
//                 this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
//                 this.exclusionMode = ExclusionMode.Ignore;
//             }
//         }
//     }
// }
