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
import qs.modules.extendedbar
import qs.modules.clipboard
import qs.modules.bar
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

        FileView {
            id: settingsWatcher
            path: Qt.resolvedUrl("../settings.json")
            watchChanges: true
            onFileChanged: settingsWatcher.reload()
            onLoaded: {
                const settings = JSON.parse(settingsWatcher.text());
                root.style = settings.theme || "neumorphic";
                console.log("Settings loaded: ", settingsWatcher.text());
            }
            onLoadFailed: {
                console.log("Failed to load settings");
            }
        }

        anchors {
            top: true
            left: true
            right: true
        }

        Item {
            id: barComponent
            width: parent.width
            height: 50

            StyledRect {
                childContainerHeight: parent.height

                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                    right: parent.right
                    topMargin: 10
                    leftMargin: 10
                    rightMargin: 10
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 4

                    Workspaces {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
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
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        NavButtons {}
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
