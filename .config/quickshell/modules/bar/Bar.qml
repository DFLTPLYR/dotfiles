import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.assets
import qs.components
import qs.modules
import qs.modules.extendedbar
import qs.services
// component
import qs.utils

Variants {
    // Rectangle {
    //     id: barComponent
    //     width: parent.width
    //     height: 40
    //     color: Scripts.setOpacity(ColorPalette.background, 0.8)
    //     RowLayout {
    //         anchors.fill: parent
    //         Rectangle {
    //             Layout.preferredWidth: parent.width * 0.25
    //             height: 32
    //             color: "transparent"
    //             Workspaces {
    //             }
    //         }
    //         Item {
    //             Layout.fillHeight: true
    //             Layout.fillWidth: true
    //             opacity: extendedBarLoader.shouldBeVisible ? 0 : 1
    //             Text {
    //                 color: ColorPalette.color14
    //                 font.family: FontProvider.fontMaterialRounded
    //                 text: `${TimeService.hoursPadded} : ${TimeService.minutesPadded}... ${TimeService.ampm}`
    //                 horizontalAlignment: Text.AlignHCenter
    //                 verticalAlignment: Text.AlignVCenter
    //                 anchors.verticalCenter: parent.verticalCenter
    //                 anchors.horizontalCenter: parent.horizontalCenter
    //                 width: parent.width
    //                 font.bold: true
    //                 font.pixelSize: {
    //                     var minSize = 10;
    //                     return Math.max(minSize, Math.min(parent.height, parent.width) * 0.2);
    //                 }
    //             }
    //             Behavior on opacity {
    //                 AnimationProvider.NumberAnim {
    //                 }
    //             }
    //         }
    //         Rectangle {
    //             Layout.preferredWidth: parent.width * 0.25
    //             height: 32
    //             color: "transparent"
    //             NavButtons {
    //             }
    //         }
    //     }
    // }

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

        Item {
            id: barComponent

            layer.enabled: true
            width: parent.width
            implicitHeight: 40

            anchors {
                topMargin: 5
                leftMargin: 5
                rightMargin: 5
                bottomMargin: 5
                left: parent.left
                right: parent.right
                top: parent.top
            }

            Rectangle {
                width: parent.width - 10
                height: 30
                radius: 2
            }

            Rectangle {
                x: 5
                y: 5
                radius: 2
                width: parent.width - 10
                height: 30
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 4

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Row {
                            spacing: 2
                            anchors.fill: parent

                            Repeater {
                                model: Hyprland.workspaces

                                delegate: Item {
                                    layer.enabled: true
                                    width: parent.height
                                    height: parent.height

                                    Rectangle {
                                        width: parent.height
                                        height: parent.height
                                        color: (modelData.active && modelData.focused) ? ColorPalette.color2 : ColorPalette.color14
                                        radius: 4
                                        border.width: (modelData.active && modelData.focused) ? 1 : 0.5
                                        border.color: (modelData.active && modelData.focused) ? ColorPalette.color14 : ColorPalette.color2

                                        Text {
                                            color: (modelData.active && modelData.focused) ? ColorPalette.color14 : ColorPalette.color2
                                            anchors.centerIn: parent
                                            text: modelData.id >= -1 ? modelData.id : "S"
                                            font.family: FontProvider.fontSometypeMono
                                            font.pixelSize: {
                                                var minSize = 10;
                                                return Math.max(minSize, Math.min(parent.height, parent.width) * 0.7);
                                            }
                                        }

                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            modelData.active();
                                        }
                                    }

                                }

                            }

                        }

                    }

                    Item {
                        Layout.preferredWidth: Math.round(parent.width * 0.7)
                        Layout.fillHeight: true
                        layer.enabled: true

                        Text {
                            color: ColorPalette.color2
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

                        Behavior on opacity {
                            AnimationProvider.NumberAnim {
                            }

                        }

                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        NavButtons {
                        }

                    }

                }

            }

        }

        LazyLoader {
            id: extendedBarLoader

            property bool shouldBeVisible: false
            property real animProgress: 0

            active: true

            component: ExtendedBar {
                anchor.window: screenRoot
                animProgress: extendedBarLoader.animProgress
                shouldBeVisible: extendedBarLoader.shouldBeVisible
            }

        }

        GlobalShortcut {
            id: resourceDashboard

            name: "showResourceBoard"
            description: "Show Resource Dashboard"
            onPressed: {
                if (extendedBarLoader.shouldBeVisible) {
                    extendedBarLoader.shouldBeVisible = false;
                    extendedBarLoader.animProgress = 0;
                    return ;
                }
                if (Hyprland.focusedMonitor.name !== screenRoot.screen.name)
                    return ;

                extendedBarLoader.shouldBeVisible = true;
                extendedBarLoader.animProgress = extendedBarLoader.shouldBeVisible ? 1 : 0;
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
