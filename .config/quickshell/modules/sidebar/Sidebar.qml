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
            screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
            implicitWidth: Math.min(500, screen.width)
            color: 'transparent'

            anchors {
                top: true
                right: true
                bottom: true
            }

            margins {
                top: Math.round(height / 2)
                right: 10
                bottom: Math.round(height / 10)
            }

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

            Rectangle {
                id: sidebarBackground
                anchors.fill: parent

                color: Scripts.setOpacity(Colors.background, 0.8)
                radius: 12
                border.color: Colors.color12
                clip: true

                Item {
                    anchors.fill: parent
                    anchors.margins: 8

                    ColumnLayout {
                        id: sidebarClip
                        width: parent.width
                        height: parent.height
                        anchors.centerIn: parent

                        Tabs {
                            // for RowLayout
                            // Layout.preferredWidth: 10
                            // Layout.fillHeight: true
                            // for ColumnLayout
                            Layout.preferredHeight: 5
                            Layout.fillWidth: true
                        }

                        TabContent {
                            id: container
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }
                    }

                    // RowLayout {
                    //     id: sidebarClip
                    //     width: parent.width
                    //     height: parent.height
                    //     anchors.centerIn: parent

                    //     TabContent {
                    //         id: container
                    //         Layout.fillHeight: true
                    //         Layout.fillWidth: true
                    //     }

                    //     Tabs {
                    //         Layout.preferredWidth: 10
                    //         Layout.fillHeight: true
                    //     }
                    // }
                }

                transform: Translate {
                    x: (1.0 - animProgress) * width
                }
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
