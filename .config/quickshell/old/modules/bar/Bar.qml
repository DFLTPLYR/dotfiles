import QtQuick
import QtQml.Models
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

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

        implicitHeight: Config.navbar.side ? screen.height : Config.navbar.height
        implicitWidth: Config.navbar.side ? Config.navbar.width : screen.width

        anchors {
            left: ["left", "top", "bottom"].includes(Config.navbar.position)
            right: ["right", "top", "bottom"].includes(Config.navbar.position)
            top: ["right", "top", "left"].includes(Config.navbar.position)
            bottom: ["right", "bottom", "left"].includes(Config.navbar.position)
        }

        Item {
            id: barComponent

            width: Config.navbar.side ? Config.navbar.width : parent.width
            height: Config.navbar.side ? parent.height : Config.navbar.height

            StyledRect {
                id: layoutSlotContainer
                childContainerHeight: parent.height

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

                StyledLayout {
                    id: layoutContainer
                    isPortrait: Config.navbar.side

                    anchors {
                        fill: parent
                        leftMargin: 0
                        rightMargin: 0
                    }

                    StyledSlot {
                        id: left
                        alignment: Config.navbar.side ? Qt.AlignTop : Qt.AlignLeft
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    StyledSlot {
                        id: center
                        alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    StyledSlot {
                        id: right
                        alignment: Config.navbar.side ? Qt.AlignBottom : Qt.AlignRight
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Variants {
                model: Config.navbar.module
                delegate: LazyLoader {
                    id: loader
                    property var modelData
                    Component.onCompleted: {
                        const model = modelData.module;
                        const comp = barComponent.getComponentByName(model);
                        component = comp;
                        active = true;
                    }
                    onItemChanged: {
                        const parent = {
                            "left": left,
                            "right": right,
                            "center": center
                        };
                        item.parent = parent[modelData.position];
                    }
                }
            }

            function getComponentByName(name) {
                switch (name.toLowerCase()) {
                case "clock":
                    return clockModule;
                case "workspaces":
                    return workspacesModule;
                case "powerbtn":
                    return powerButtonModule;
                default:
                    return null;
                }
            }

            Component {
                id: clockModule
                Clock {}
            }

            Component {
                id: workspacesModule
                WorkSpaces {}
            }

            Component {
                id: powerButtonModule
                PowerButton {}
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
                    if (Hyprland.focusedMonitor.name !== screenRoot.screen.name)
                        return;

                    extendedBarLoader.shouldBeVisible = true;
                    extendedBarLoader.active = true;
                    extendedBarLoader.animProgress = extendedBarLoader.shouldBeVisible ? 1 : 0;
                }
            }

            LazyLoader {
                id: extendedBarLoader

                property bool shouldBeVisible: false
                property real animProgress: 0

                active: false
                component: ExtendedBar {
                    anchor.window: screenRoot
                    animProgress: extendedBarLoader.animProgress
                    shouldBeVisible: extendedBarLoader.shouldBeVisible
                    onHide: {
                        return Qt.callLater(() => {
                            return extendedBarLoader.active = false;
                        }, 10);
                    }
                }
            }
        }
    }
}
