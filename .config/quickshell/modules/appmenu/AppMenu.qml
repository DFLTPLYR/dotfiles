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
                        root.toggle();
                        event.accepted = true;
                        break;
                    case Qt.Key_Backspace:
                        searchValue = searchValue.slice(0, -1);
                        event.accepted = true;
                        break;
                    case Qt.Key_Enter:
                    case Qt.Key_Return:
                        grid.openApp();
                        searchValue = "";
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
            Item {
                width: Math.round(appMenuRoot.isPortrait ? screen.width / 1.5 : screen.width / 2)
                height: Math.round(appMenuRoot.isPortrait ? screen.height / 2.25 : screen.height / 2)
               
                StyledRect {
                    x: Math.round(screen.width / 2 - width / 2)
                    y: Math.round(screen.height / 2 - height / 2)
                    childContainerHeight: parent.height * animProgress
                    
                    // Display
                    ColumnLayout {
                      anchors.fill: parent
                      Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.9
                        RowLayout {
                          anchors.fill: parent


                          //Wallpaper Preview
                          Item {
                            Layout.preferredWidth: parent.width * 0.4
                            Layout.fillHeight: true

                            Rectangle {
                              anchors.fill: parent
                              color: 'transparent'

                                MaskWrapper {
                                    radius: 8
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    sourceItem: Image {
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: WallpaperStore.currentWallpapers[screen.name] ?? null
                                        cache: true
                                        asynchronous: true
                                        smooth: true
                                        visible: false
                                    }
                                }

                            }
                          }

                        
                          // App Grid
                          Item {
                            Layout.preferredWidth: parent.width * 0.6
                            Layout.fillHeight: true

                            Rectangle {
                              id: container

                              anchors.fill: parent
                              color: 'transparent'

                              AppListView {
                                id: grid
                                searchText: searchValue
                              }
                            }
                          }
                                                  }
                      }
                      // Search Bar
                    Item {
                        Layout.preferredHeight: parent.height * 0.1
                        Layout.fillWidth: true
                        Text {
                            id: searchText
                            text: qsTr(`Search: ${searchValue}`)
                            font.pixelSize: 24
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            color: ColorPalette.color15
                        }
                      }                    
                    }
                }  
              }
            Rectangle {
                width: Math.round(appMenuRoot.isPortrait ? screen.width / 1.5 : screen.width / 2)
                height: Math.round(appMenuRoot.isPortrait ? screen.height / 2.25 : screen.height / 2)
                visible: false
                x: Math.round(screen.width / 2 - width / 2)
                y: Math.round(screen.height / 2 - height / 2)

                color: Scripts.setOpacity(ColorPalette.background, 0.9)
                opacity: animProgress

                radius: 16
                scale: animProgress

                Column {
                    anchors.fill: parent

                    // Item list
                    Rectangle {
                        height: Math.round(parent.height * 0.9)
                        width: parent.width
                        color: Scripts.setOpacity(ColorPalette.color10, 0.2)
                        topLeftRadius: 16
                        topRightRadius: 16

                        clip: true
                        RowLayout {
                            anchors.fill: parent

                            Rectangle {
                                Layout.preferredWidth: parent.width * 0.4
                                Layout.fillHeight: true
                                color: 'transparent'

                                MaskWrapper {
                                    radius: 8
                                    anchors.fill: parent
                                    sourceItem: Image {
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: WallpaperStore.currentWallpapers[screen.name] ?? null
                                        cache: true
                                        asynchronous: true
                                        smooth: true
                                        visible: false
                                    }
                                }
                            }

                        }
                    }


                }
            }
        }
    }
}
