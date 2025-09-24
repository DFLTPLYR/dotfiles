import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// component
import qs.utils
import qs.assets
import qs.modules
import qs.services
import qs.components
import qs.modules.extendedbar

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: screenRoot
        required property ShellScreen modelData
        property bool isExtendedBarOpen: false
        screen: modelData
        color: "transparent"
        implicitHeight: barComponent.height

        anchors {
            top: true
            left: true
            right: true
        }

        Rectangle {
            id: barComponent
            width: parent.width
            height: 40
            color: Scripts.setOpacity(ColorPalette.background, 0.8)

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.preferredWidth: parent.width * 0.25
                    height: 32
                    color: "transparent"

                    Workspaces {}
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    opacity: extendedBarLoader.shouldBeVisible ? 0 : 1

                    Behavior on opacity {
                        AnimationProvider.NumberAnim {}
                    }

                    Text {
                        color: ColorPalette.color14
                        font.family: FontProvider.fontMaterialRounded
                        text: `${TimeService.hoursPadded} : ${TimeService.minutesPadded}... ${TimeService.ampm}`
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        font.bold: true
                        font.pixelSize: {
                            var minSize = 10;
                            return Math.max(minSize, Math.min(parent.height, parent.width) * 0.2);
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: parent.width * 0.25
                    height: 32
                    color: "transparent"

                    NavButtons {}
                }
            }
        }

        LazyLoader {
            id: extendedBarLoader
            active: true
            component: ExtendedBar {
                anchor.window: screenRoot
                animProgress: extendedBarLoader.animProgress
                shouldBeVisible: extendedBarLoader.shouldBeVisible
            }
            property bool shouldBeVisible: false
            property real animProgress: 0.0
        }

        GlobalShortcut {
            id: resourceDashboard
            name: "showResourceBoard"
            description: "Show Resource Dashboard"
            onPressed: {
                if (extendedBarLoader.shouldBeVisible) {
                    extendedBarLoader.shouldBeVisible = false;
                    extendedBarLoader.animProgress = 0;
                    return;
                }
                if (Hyprland.focusedMonitor.name !== screenRoot.screen.name) {
                    return;
                }
                extendedBarLoader.shouldBeVisible = true;
                extendedBarLoader.animProgress = extendedBarLoader.shouldBeVisible ? 1 : 0;
            }
        }

        LazyLoader {
            id: clipBoardLoader
            active: false
            component: ClipBoard {
                animProgress: clipBoardLoader.animProgress
                shouldBeVisible: clipBoardLoader.shouldBeVisible
                onHide: () => {
                    clipBoardLoader.shouldBeVisible = false;
                    return Qt.callLater(() => clipBoardLoader.active = false, 40);
                }
            }
            property bool shouldBeVisible: false
            property real animProgress: 0.0
        }

        GlobalShortcut {
            id: clipBoard
            name: "showClipBoard"
            description: "Show Clipboard history"
            onPressed: {
                if (clipBoardLoader.shouldBeVisible) {
                    clipBoardLoader.animProgress = 0;
                    clipBoardLoader.shouldBeVisible = false;
                    return Qt.callLater(() => clipBoardLoader.active = false, 40);
                }
                if (Hyprland.focusedMonitor.name !== screenRoot.screen.name) {
                    clipBoardLoader.animProgress = 0;
                    clipBoardLoader.shouldBeVisible = false;
                    return Qt.callLater(() => clipBoardLoader.active = false, 40);
                }
                clipBoardLoader.shouldBeVisible = true;
                clipBoardLoader.animProgress = 1;
                return Qt.callLater(() => clipBoardLoader.active = true, 40);
            }
        }
    }
}
