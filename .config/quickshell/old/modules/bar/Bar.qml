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

        implicitHeight: Navbar.config.side ? screen.height : Navbar.config.height
        implicitWidth: Navbar.config.side ? Navbar.config.width : screen.width

        anchors {
            left: ["left", "top", "bottom"].includes(Navbar.config.position)
            right: ["right", "top", "bottom"].includes(Navbar.config.position)
            top: ["right", "top", "left"].includes(Navbar.config.position)
            bottom: ["right", "bottom", "left"].includes(Navbar.config.position)
        }

        Item {
            id: barComponent

            width: Navbar.config.side ? Navbar.config.width : parent.width
            height: Navbar.config.side ? parent.height : Navbar.config.height

            StyledRect {
                id: layoutSlotContainer
                childContainerHeight: parent.height

                anchors {
                    top: Navbar.config.main.anchors.top ? parent.top : undefined
                    left: Navbar.config.main.anchors.left ? parent.left : undefined
                    bottom: Navbar.config.main.anchors.bottom ? parent.bottom : undefined
                    right: Navbar.config.main.anchors.right ? parent.right : undefined
                    topMargin: Navbar.config.main.margins.top
                    leftMargin: Navbar.config.main.margins.left
                    rightMargin: Navbar.config.main.margins.right
                    bottomMargin: Navbar.config.main.margins.bottom
                }

                StyledLayout {
                    id: layoutContainer
                    isPortrait: Navbar.config.side

                    anchors {
                        fill: parent
                        leftMargin: 0
                        rightMargin: 0
                    }

                    StyledSlot {
                        id: left
                        alignment: Navbar.config.side ? Qt.AlignTop : Qt.AlignLeft
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
                        alignment: Navbar.config.side ? Qt.AlignBottom : Qt.AlignRight
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Variants {
                model: Navbar.config.module
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
