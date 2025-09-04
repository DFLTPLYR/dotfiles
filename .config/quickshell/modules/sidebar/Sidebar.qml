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
                visible: root.isVisible
                color: 'transparent'

                RowLayout {
                    id: popupWrapper
                    implicitWidth: sideDock.width
                    implicitHeight: sideDock.height
                    x: (1.0 - animProgress) * width
                    layoutDirection: Qt.RightToLeft
                    Rectangle {
                        id: sideDock
                        width: 50
                        height: Math.max(800, sidebarRoot.isPortrait ? screen.height / 2 : screen.height / 2)
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
                                    anchors.margins: 4

                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                }
                            }
                            // QuickToolussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    Repeater {
                                        model: [
                                            {
                                                name: "Calculator",
                                                icon: "calculate"
                                            },
                                            {
                                                name: "Apps",
                                                icon: "dashboard"
                                            },
                                            {
                                                name: "Todo",
                                                icon: "list_alt"
                                            },
                                        ]
                                        delegate: Text {
                                            required property var modelData
                                            text: modelData.icon
                                            color: Assets.color14
                                            font.family: FontAssets.fontMaterialRounded
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: {
                                                const minSize = 10;
                                                return Math.max(minSize, Math.min(parent.height, parent.width));
                                            }
                                        }
                                    }
                                }
                            }
                            // Miscellaneoussy
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: 'transparent'
                                border.color: Assets.color10
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                    Text {
                                        text: "\ue1ff"
                                        color: Assets.color14
                                        font.family: FontAssets.fontMaterialRounded
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: {
                                            const minSize = 10;
                                            return Math.max(minSize, Math.min(parent.height, parent.width));
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 50
                        height: 200
                    }
                }
            }
        }
    }
}
