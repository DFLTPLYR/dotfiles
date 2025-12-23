import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
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
            readonly property bool isPortrait: screen.height >= screen.width
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            anchors {
                top: true
                bottom: true
                right: true
                left: true
            }

            Item {
                anchors.centerIn: parent
                width: sidebarRoot.isPortrait ? parent.width / 1.2 : parent.width / 1.5
                height: parent.height * 0.5
                RowLayout {
                    id: layout
                    anchors.fill: parent
                    spacing: 6
                    opacity: 1 * sidebarRoot.animProgress

                    Rectangle {
                        color: 'teal'
                        Layout.fillWidth: true
                        Layout.maximumWidth: parent.width / 3
                        Layout.fillHeight: true

                        Text {
                            anchors.centerIn: parent
                            text: parent.width + 'x' + parent.height
                        }
                    }

                    Rectangle {
                        color: 'plum'
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            anchors.centerIn: parent
                            text: parent.width + 'x' + parent.height
                        }
                    }
                }
            }

            // Contents
            // StyledRect {
            //     width: 500 * sidebarRoot.animProgress
            //     height: 500 * sidebarRoot.animProgress
            //     fill: true
            //     x: Math.round(screen.width / 2 - width / 2)
            //     y: Math.round(screen.height / 2 - height / 2)
            //     color: Qt.rgba(0, 0, 0, 0.5)
            // }

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
