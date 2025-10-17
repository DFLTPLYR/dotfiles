import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
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

        StyledRect {
            id: barComponent
            childContainerHeight: 40
            anchors {
                leftMargin: 10
                rightMargin: 10
                left: parent.left
                right: parent.right
            }

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
                                        font.bold: true
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        modelData.activate();
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

                    Behavior on opacity {
                        AnimationProvider.NumberAnim {}
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
                    return;
                }
                if (Hyprland.focusedMonitor.name !== screenRoot.screen.name)
                    return;

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
