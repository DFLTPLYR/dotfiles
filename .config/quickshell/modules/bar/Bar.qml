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
                        PowerButton {}
                    }
                }
            }
            Repeater {
                model: ScriptModel {
                    values: Config.navbar.module
                }
                delegate: Item {
                    visible: false
                    Component.onCompleted: {
                        const comp = barComponent.getComponentByName(modelData.module);
                        const parentMap = {
                            "left": left,
                            "center": center,
                            "right": right
                        };
                        const parent = parentMap[modelData.position];
                        if (comp && parent)
                            comp.createObject(parent);
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
                    return clockModule;
                default:
                    return null;
                }
            }

            Component {
                id: clockModule
                Clock {
                    property bool module: true
                }
            }

            Component {
                id: workspacesModule
                WorkSpaces {
                    property bool module: true
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
        }
    }
}
