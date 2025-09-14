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
            active: isExtendedBarOpen
            component: ExtendedBar {
                visible: Hyprland.focusedMonitor.name === screenRoot.screen.name
                anchor.window: screenRoot
            }
        }

        GlobalShortcut {
            id: resourceDashboard
            name: "showResourceBoard"
            description: "Show Resource Dashboard"
            onPressed: {
                Qt.callLater(() => {
                    screenRoot.isExtendedBarOpen = true;
                });
            }
        }
    }
}
