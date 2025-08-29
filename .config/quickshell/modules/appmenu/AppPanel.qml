import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

import qs.utils
import qs.assets
import qs.services
import qs.components

Scope {
    id: root

    property bool isVisible: false
    signal toggle

    GlobalShortcut {
        id: cancelKeybind
        name: "showAppMenu"
        description: "Show Resource Dashboard"
        onPressed: {
            Qt.callLater(() => {
                root.isVisible = true;
                root.toggle();
            });
        }
    }

    LazyLoader {
        active: isVisible
        component: PanelWrapper {
            id: appMenuRoot
            implicitWidth: 0

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            Connections {
                target: root
                function onToggle() {
                    appMenuRoot.shouldBeVisible = !appMenuRoot.shouldBeVisible;
                }
            }

            KeyboardEventHandler {
                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    switch (event.key) {
                    case Qt.Key_Escape:
                        searchValue = "";
                        GlobalState.toggleDrawer("appMenu");
                        event.accepted = true;
                        break;
                    case Qt.Key_Backspace:
                        searchValue = searchValue.slice(0, -1);
                        event.accepted = true;
                        break;
                    case Qt.Key_Enter:
                    case Qt.Key_Return:
                        grid.openApp();
                        event.accepted = true;
                        break;
                    case Qt.Key_Left:
                        if (grid.currentIndex > 0)
                            grid.currentIndex -= 1;
                        event.accepted = true;
                        break;
                    case Qt.Key_Right:
                        if (grid.currentIndex < grid.count - 1)
                            grid.currentIndex += 1;
                        event.accepted = true;
                        break;
                    case Qt.Key_Up:
                        grid.currentIndex = Math.max(0, grid.currentIndex - grid.columns);
                        event.accepted = true;
                        break;
                    case Qt.Key_Down:
                        grid.currentIndex = Math.min(grid.count - 1, grid.currentIndex + grid.columns);
                        event.accepted = true;
                        break;
                    default:
                        if (event.text.length > 0) {
                            searchValue += event.text;
                            event.accepted = true;
                        }
                    }
                }
            }

            property string searchValue: ''

            Rectangle {
                width: Math.round(appMenuRoot.isPortrait ? screen.width / 1.5 : screen.width / 2)
                height: Math.round(appMenuRoot.isPortrait ? screen.height / 2.25 : screen.height / 2)

                x: Math.round(screen.width / 2 - width / 2)
                y: Math.round(screen.height / 2 - height / 2)

                color: Scripts.setOpacity(Assets.background, 0.6)
                opacity: animProgress

                radius: 16
                scale: animProgress
                transformOrigin: Item.Center
                clip: true
                Column {
                    anchors.fill: parent

                    // Item list
                    Item {
                        height: Math.round(parent.height * 0.9)
                        width: parent.width

                        Rectangle {
                            anchors.fill: parent
                            color: Scripts.setOpacity(Assets.color10, 0.2)
                        }

                        RowLayout {
                            anchors.fill: parent

                            Rectangle {
                                Layout.preferredWidth: parent.width * 0.3
                                Layout.fillHeight: true
                                clip: true
                                color: 'transparent'

                                Image {
                                    id: name
                                    anchors.fill: parent
                                    fillMode: Image.PreserveAspectCrop
                                    source: WallpaperStore.currentWallpapers[screen.name] ?? null
                                }
                            }

                            Rectangle {
                                id: container

                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                color: 'transparent'

                                AppListView {
                                    id: grid
                                    searchText: searchValue
                                }
                            }
                        }
                    }

                    // Search Bar
                    Item {
                        height: Math.round(parent.height * 0.1)
                        width: parent.width

                        Rectangle {
                            anchors.fill: parent
                            color: Scripts.hexToRgba(Assets.background, 0.1)
                        }

                        Text {
                            id: searchText
                            text: qsTr(`Search: ${searchValue}`)
                            font.pixelSize: 24
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            color: Assets.color15
                        }
                    }
                }
            }
        }
    }
}
