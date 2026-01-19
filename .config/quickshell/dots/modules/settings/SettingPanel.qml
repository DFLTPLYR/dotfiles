import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland

import qs.utils
import qs.config
import qs.components
import qs.modules.settings.modules

Scope {
    Connections {
        target: Config
        function onOpenSettingsPanelChanged() {
            settingsLoader.active = !settingsLoader.active;
        }
    }

    LazyLoader {
        id: settingsLoader
        component: FloatingWindow {
            id: root
            title: "SettingsPanel"
            property int page: 0
            property ShellScreen selectedScreen: Quickshell.screens.find(w => w.name === Config.focusedMonitor.name)
            readonly property bool isPortrait: screen.height > screen.width
            readonly property size panelSize: isPortrait ? Qt.size(screen.width * 0.8, screen.height * 0.6) : Qt.size(screen.width * 0.6, screen.height * 0.8)

            minimumSize: panelSize
            maximumSize: panelSize

            color: Qt.rgba(0, 0, 0, 0.8)

            GridLayout {
                columns: 2
                anchors.fill: parent

                // sidebar
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40

                    ListView {
                        anchors.fill: parent
                        spacing: 1
                        model: ["general", "navbar", "wallpaper"]
                        delegate: Item {
                            width: 40
                            height: 40

                            Rectangle {
                                anchors.fill: parent
                                color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                                radius: ma.containsMouse ? 8 : 0

                                FontIcon {
                                    anchors.centerIn: parent
                                    text: getIcon(modelData)
                                    font.pixelSize: parent.height
                                    color: ma.containsMouse || root.page === index ? "white" : Qt.rgba(1, 1, 1, 0.6)

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 350
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }

                                Behavior on radius {
                                    NumberAnimation {
                                        duration: 350
                                        easing.type: Easing.InOutQuad
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 350
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            MouseArea {
                                id: ma
                                hoverEnabled: true
                                anchors.fill: parent
                                onClicked: {
                                    page = index;
                                }
                            }
                        }
                    }
                }

                // content
                StackLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    currentIndex: root.page
                    Layout.rightMargin: 0

                    General {}

                    Navbar {}

                    // Wallpaper
                    Wallpaper {}
                }
            }
        }
    }

    LazyLoader {
        id: settingsContainer
        property bool shouldBeVisible: false
        component: PanelWrapper {
            id: settingsRoot
            property ShellScreen selectedScreen: Quickshell.screens.find(w => w.name === Config.focusedMonitor.name)
            readonly property bool isPortrait: screen.height > screen.width
            readonly property size panelSize: isPortrait ? Qt.size(screen.width * 0.8, screen.height * 0.6) : Qt.size(screen.width * 0.6, screen.height * 0.8)

            mask: Region {
                item: container
            }

            shouldBeVisible: settingsContainer.shouldBeVisible

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            StyledRect {
                id: container
                width: settingsRoot.panelSize.width
                height: settingsRoot.panelSize.height
                color: Scripts.setOpacity(Colors.color.background, 0.8)
                opacity: settingsRoot.animProgress
                x: screen.width / 2 - width / 2
                y: screen.height / 2 - height / 2
            }

            onHidden: {
                settingsContainer.active = false;
            }
        }
    }

    function getIcon(name) {
        switch (name) {
        case "general":
            return "gear";
        case "navbar":
            return `bar-${Config.navbar.position}`;
        case "wallpaper":
            return "hexagon-image";
        default:
            return "?";
        }
    }
}
