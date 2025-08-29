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
                    width: Math.max(300, sidebarRoot.isPortrait ? screen.width / 2 : screen.width / 4)
                    height: Math.max(800, sidebarRoot.isPortrait ? screen.height / 2 : screen.height / 2)
                    x: (1.0 - animProgress) * width

                    Rectangle {
                        anchors.fill: parent
                        color: Scripts.setOpacity(Assets.background, 0.6)
                        radius: 10
                        border.color: Scripts.setOpacity(Assets.color15, 0.6)
                        clip: true

                        Item {
                            anchors.fill: parent
                            anchors.margins: 8

                            ColumnLayout {
                                id: sidebarClip
                                anchors.fill: parent
                                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                                TabBar {
                                    id: bar
                                    contentHeight: 32
                                    Layout.fillWidth: true
                                    currentIndex: 0
                                    spacing: 4

                                    background: Rectangle {
                                        anchors.fill: parent
                                        color: 'transparent'
                                        radius: 24
                                    }

                                    Repeater {
                                        model: [
                                            {
                                                name: "Calculator",
                                                icon: "\uf1ec"
                                            },
                                            {
                                                name: "Todo",
                                                icon: "\uf02e"
                                            },
                                            {
                                                name: "System",
                                                icon: "\uf2db"
                                            },
                                            {
                                                name: "Websearch",
                                                icon: "\uf2db"
                                            }
                                        ]

                                        TabButton {
                                            contentItem: Text {
                                                anchors.fill: parent
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                text: `${qsTr(modelData.icon)} ${qsTr(modelData.name)}`
                                                color: bar.currentIndex === index ? Assets.color11 : Assets.color10
                                                font.pixelSize: bar.contentHeight * 0.5
                                            }
                                            background: Rectangle {
                                                anchors.fill: parent
                                                color: bar.currentIndex === index ? Assets.color1 : Assets.color0
                                                radius: 4
                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: 250
                                                        easing.type: Easing.InOutQuad
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                TabContent {
                                    currentIndex: bar.currentIndex
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
