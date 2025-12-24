import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

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
                width: sidebarRoot.isPortrait ? (parent.width / 1.2) * sidebarRoot.animProgress : (parent.width / 1.5) * sidebarRoot.animProgress
                height: (parent.height * 0.5) * sidebarRoot.animProgress

                RowLayout {
                    id: layout
                    anchors.fill: parent
                    spacing: 6
                    opacity: 1 * sidebarRoot.animProgress

                    Rectangle {
                        color: Qt.rgba(0, 0, 0, 0.5)
                        Layout.fillWidth: true
                        Layout.maximumWidth: parent.width / 3
                        Layout.fillHeight: true

                        clip: true
                    }

                    Rectangle {
                        color: Qt.rgba(0, 0, 0, 0.5)
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            anchors.fill: parent
                            spacing: 10

                            FolderListModel {
                                id: folderModel
                                folder: Qt.resolvedUrl(`${Quickshell.env("HOME") + "/Pictures"}`)
                                nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.bmp"]
                            }

                            model: folderModel
                            delegate: Item {
                                required property var modelData

                                width: parent.width
                                height: 40
                                visible: folderModel.isFolder(modelData.index)

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.fileName
                                    color: "white"
                                    font.pixelSize: 16
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (folderModel.isFolder(modelData.index)) {
                                            folderModel.folder = modelData.filePath;
                                        }
                                    }
                                }
                            }
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
