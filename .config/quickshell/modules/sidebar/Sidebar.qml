import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

import qs.utils
import qs.assets
import qs.services
import qs.components

Scope {
    id: root

    property bool isVisible: false
    signal toggle

    GlobalShortcut {
        id: cancelKeybind
        name: "showSideBar"
        description: "Cancel current action"
        onPressed: {
            Qt.callLater(() => {
                root.isVisible = true;
                root.toggle();
            });
        }
    }

    LazyLoader {
        active: isVisible
        component: PanelWrapper {
            id: sidebarRoot
            implicitWidth: 0

            anchors {
                top: true
                right: true
                bottom: true
            }

            Connections {
                target: root
                function onToggle() {
                    sidebarRoot.shouldBeVisible = !sidebarRoot.shouldBeVisible;
                }
            }

            PopupWindow {
                id: sidebarPopup
                anchor.window: sidebarRoot
                anchor.rect.x: parentWindow.width
                anchor.rect.y: parentWindow.height / 2 - height / 2
                implicitWidth: popupWrapper.width
                implicitHeight: popupWrapper.height
                visible: true
                color: 'transparent'

                Item {
                    id: popupWrapper
                    width: 75
                    height: Math.max(800, sidebarRoot.isPortrait ? screen.height / 2 : screen.height / 2)
                    x: (1.0 - animProgress) * width

                    Rectangle {
                        anchors.fill: parent
                        color: Scripts.setOpacity(Assets.background, 0.4)
                        radius: 10
                        border.color: Assets.color10
                        clip: true

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            // Statussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10

                                ColumnLayout {
                                    anchors.fill: parent
                                }
                            }
                            // QuickToolussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10
                            }
                            // Miscellaneoussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10
                            }
                        }

                        // Item {
                        //     anchors.fill: parent
                        //     anchors.margins: 8

                        //     TabBar {
                        //         id: bar
                        //         anchors.fill: parent
                        //         currentIndex: 0
                        //         spacing: 4

                        //         background: Rectangle {
                        //             anchors.fill: parent
                        //             color: 'transparent'
                        //             radius: 24
                        //         }

                        //         Repeater {
                        //             model: [
                        //                 {
                        //                     name: "Calculator",
                        //                     icon: "\uf1ec"
                        //                 },
                        //                 {
                        //                     name: "Todo",
                        //                     icon: "\uf02e"
                        //                 },
                        //                 {
                        //                     name: "System",
                        //                     icon: "\uf2db"
                        //                 }
                        //             ]

                        //             TabButton {
                        //                 contentItem: Text {
                        //                     Layout.fillWidth: true
                        //                     Layout.fillHeight: true
                        //                     horizontalAlignment: Text.AlignHCenter
                        //                     verticalAlignment: Text.AlignVCenter
                        //                     text: `${qsTr(modelData.icon)} ${qsTr(modelData.name)}`
                        //                     color: bar.currentIndex === index ? Assets.color11 : Assets.color10
                        //                     font.pixelSize: bar.contentHeight * 0.5
                        //                 }
                        //                 background: Rectangle {
                        //                     Layout.fillWidth: true
                        //                     Layout.fillHeight: true
                        //                     color: bar.currentIndex === index ? Assets.color1 : Assets.color0
                        //                     radius: 4
                        //                     Behavior on color {
                        //                         ColorAnimation {
                        //                             duration: 250
                        //                             easing.type: Easing.InOutQuad
                        //                         }
                        //                     }
                        //                 }
                        //             }
                        //         }

                        //         // TabContent {
                        //         //     currentIndex: bar.currentIndex
                        //         // }
                        //     }
                        // }
                    }
                }
            }
        }
    }
}
