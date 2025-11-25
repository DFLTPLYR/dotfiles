import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Controls
// Modules
import qs.modules.extendedbar
import qs.modules.clipboard
import qs.modules.bar

// component
import qs.config
import qs.utils
import qs.assets
import qs.services
import qs.components

Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
        id: screenRoot

        required property ShellScreen modelData
        property bool isExtendedBarOpen: false

        screen: modelData
        color: "transparent"
        implicitHeight: barComponent.height
        implicitWidth: barComponent.width

        anchors {
            left: Config.navbar.position === "left" || Config.navbar.position === "top" || Config.navbar.position === "bottom"
            right: Config.navbar.position === "right" || Config.navbar.position === "top" || Config.navbar.position === "bottom"
            top: Config.navbar.position === "top" || Config.navbar.position === "left" || Config.navbar.position === "right"
            bottom: Config.navbar.position === "bottom" || Config.navbar.position === "left" || Config.navbar.position === "right"
        }
        Item {
            id: barComponent
            width: Config.navbar.side ? Config.navbar.main.height : parent.width
            height: Config.navbar.side ? parent.height : Config.navbar.main.height

            StyledRect {
                childContainerHeight: Config.navbar.main.height

                anchors {
                    top: Config.navbar.main.anchors.top ? parent.top : undefined
                    left: Config.navbar.main.anchors.left ? parent.left : undefined
                    bottom: Config.navbar.main.anchors.bottom ? parent.bottom : undefined
                    right: Config.navbar.main.anchors.right ? parent.right : undefined
                    topMargin: Config.navbar.main.margins.top
                    leftMargin: Config.navbar.main.margins.left
                    rightMargin: Config.navbar.main.margins.right
                    bottomMargin: Config.navbar.main.margins.bottom
                  }

                RowLayout {
                    spacing: 5

                    anchors {
                        fill: parent
                        margins: 5
                    }

                    Workspaces {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.preferredWidth: Math.round(parent.width * 0.7)
                        Layout.fillHeight: true
                        layer.enabled: true

                        Text {
                            anchors {
                                verticalCenter: parent.verticalCenter
                                horizontalCenter: parent.horizontalCenter
                            }

                            color: Color.color14
                            font.family: FontProvider.fontMaterialRounded
                            text: `${TimeService.hoursPadded} : ${TimeService.minutesPadded}... ${TimeService.ampm}`
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            width: parent.width
                            font.bold: true
                            font.pixelSize: {
                                var minSize = 10;
                                return Math.max(minSize, Math.min(parent.height, parent.width) * 0.2);
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        NavButtons {}
                    }
                  }
            }

            LazyLoader {
                id: panelLoader

                property bool shouldBeVisible: false
                property real animProgress: 0

                active: false
                component: ExtendedBar {
                    anchor.window: screenRoot
                    animProgress: panelLoader.animProgress
                    shouldBeVisible: panelLoader.shouldBeVisible
                    onHide: {
                        panelLoader.shouldBeVisible = false;
                        return Qt.callLater(() => {
                            return panelLoader.active = false;
                        }, 400);
                    }
                }
            }

            GlobalShortcut {
                id: resourceDashboard

                name: "showResourceBoard"
                description: "Show Resource Dashboard"
                onPressed: {
                    if (panelLoader.shouldBeVisible) {
                        panelLoader.shouldBeVisible = false;
                        panelLoader.animProgress = 0;
                        return;
                    }
                    if (Hyprland.focusedMonitor.name !== screenRoot.screen.name)
                        return;

                    panelLoader.shouldBeVisible = true;
                    panelLoader.active = true;
                    panelLoader.animProgress = panelLoader.shouldBeVisible ? 1 : 0;
                }
            }

            LazyLoader {
                id: clipBoardLoader

                property bool shouldBeVisible: false
                property real animProgress: 0

                active: false

                component: ClipBoard {
                    animProgress: clipBoardLoader.animProgress
                    shouldBeVisible: clipBoardLoader.shouldBeVisible
                    onHide: () => {
                        clipBoardLoader.shouldBeVisible = false;
                        return Qt.callLater(() => {
                            return clipBoardLoader.active = false;
                        }, 40);
                    }
                }
            }

            GlobalShortcut {
                id: clipBoard

                name: "showClipBoard"
                description: "Show Clipboard history"
                onPressed: {
                    if (clipBoardLoader.shouldBeVisible) {
                        clipBoardLoader.animProgress = 0;
                        clipBoardLoader.shouldBeVisible = false;
                        return Qt.callLater(() => {
                            return clipBoardLoader.active = false;
                        }, 40);
                    }
                    if (Hyprland.focusedMonitor.name !== screenRoot.screen.name) {
                        clipBoardLoader.animProgress = 0;
                        clipBoardLoader.shouldBeVisible = false;
                        return Qt.callLater(() => {
                            return clipBoardLoader.active = false;
                        }, 40);
                    }
                    clipBoardLoader.shouldBeVisible = true;
                    clipBoardLoader.animProgress = 1;
                    return Qt.callLater(() => {
                        return clipBoardLoader.active = true;
                    }, 40);
                }
            }
        }
    }
}
