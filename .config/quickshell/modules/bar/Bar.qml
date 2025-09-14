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
        required property var modelData
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

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("text")
                        color: "white"
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

        // connect this to the clipboard or create a state manager
        LazyLoader {
            id: clipBoardLoader
            active: true
            component: ClipBoard {
                animProgress: clipBoardLoader.animProgress
                shouldBeVisible: clipBoardLoader.shouldBeVisible
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
                    clipBoardLoader.shouldBeVisible = false;
                    clipBoardLoader.animProgress = 0;
                    return;
                }
                if (Hyprland.focusedMonitor.name !== screenRoot.screen.name) {
                    return;
                }
                clipBoardLoader.shouldBeVisible = true;
                clipBoardLoader.animProgress = 1;
            }
        }
    }
}
