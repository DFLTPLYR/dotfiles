import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

import qs.services
import qs.assets
import qs.utils

Scope {
    id: root

    property bool isVisible: false
    signal shouldBeVisible

    GlobalShortcut {
        id: cancelKeybind
        name: "showSideBar"
        description: "Cancel current action"
        onPressed: {
            Qt.callLater(() => {
                root.isVisible = true;
                root.shouldBeVisible();
            });
        }
    }

    LazyLoader {
        active: isVisible
        component: PanelWindow {
            id: sidebarRoot
            screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

            color: 'transparent'

            anchors {
                top: true
                right: true
                bottom: true
            }

            readonly property bool isPortrait: screen.height > screen.width

            // Internal properties
            property bool shouldBeVisible: false
            property bool internalVisible: false
            property real animProgress: 0.0

            // Signals for custom behavior
            signal hidden(string drawerKey)
            signal visibilityChanged(bool value, string monitorName)

            visible: internalVisible
            focusable: internalVisible

            // Manual animator
            NumberAnimation on animProgress {
                id: anim
                duration: 300
                easing.type: Easing.InOutQuad
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

            onShouldBeVisibleChanged: {
                const target = shouldBeVisible ? 1.0 : 0.0;
                if (anim.to !== target || !anim.running) {
                    anim.to = target;
                    anim.restart();
                }
            }

            onAnimProgressChanged: {
                if (animProgress > 0 && !internalVisible) {
                    internalVisible = true;
                } else if (!shouldBeVisible && animProgress === 0.00) {
                    internalVisible = false;
                    root.isVisible = false;
                }
            }

            onScreenChanged: {
                const target = shouldBeVisible ? 1.0 : 0.0;
                anim.stop();
                animProgress = target === 1.0 ? 0.0 : 1.0;
                anim.to = target;
                Qt.callLater(function () {
                    anim.restart();
                });
            }

            Connections {
                target: root
                function onShouldBeVisible() {
                    shouldBeVisible = !shouldBeVisible;
                }
            }

            // set up
            Component.onCompleted: {
                if (this.WlrLayershell != null) {
                    this.WlrLayershell.layer = WlrLayer.Overlay;
                    this.exclusiveZone = 0;
                }
            }
        }
    }
}
