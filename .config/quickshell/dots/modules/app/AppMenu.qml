import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.components
import qs.config

Scope {
    LazyLoader {
        id: appMenuLoader
        property bool shouldBeVisible: false
        component: PanelWrapper {
            id: screenPanel

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "AppMenu"

            color: "transparent"
            shouldBeVisible: appMenuLoader.shouldBeVisible

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            PopupWindow {
                anchor.window: screenPanel
                anchor.rect.x: parentWindow.width / 2 - width / 2
                anchor.rect.y: (parentWindow.screen.height / 2 - height / 2)
                implicitWidth: screenPanel.isPortrait ? parentWindow.screen.width * 0.8 : parentWindow.screen.width * 0.5
                implicitHeight: parentWindow.screen.height * 0.6
                color: "transparent"
                visible: screenPanel.internalVisible

                StyledRect {
                    anchors.fill: parent
                    opacity: screenPanel.animProgress
                    color: "transparent"

                    Behavior on height {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    GridLayout {
                        anchors.fill: parent

                        Rectangle {
                            Layout.preferredWidth: parent.width * 0.3
                            Layout.fillHeight: true
                            color: Qt.rgba(0, 0, 0, 0.5)

                            Image {
                                height: parent.height
                                width: parent.width
                                sourceSize.width: screen.width
                                sourceSize.height: screen.height
                                fillMode: Image.PreserveAspectCrop
                                source: {
                                    const filePath = Config.general.useCustomWallpaper ? Config.general.customWallpaper.find(wallpaperItem => wallpaperItem.monitor === screen.name)?.path : Config.general.wallpapers.find(wallpaperItem => wallpaperItem.monitor === screen.name)?.path;
                                    if (filePath === undefined) {
                                        return "";
                                    }
                                    return Qt.resolvedUrl(filePath);
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Qt.rgba(0, 0, 0, 0.5)
                        }
                    }
                }
            }

            onHidden: {
                appMenuLoader.active = false;
            }
        }
    }
    Connections {
        target: Config
        function onOpenAppLauncherChanged() {
            if (!appMenuLoader.active) {
                appMenuLoader.active = true;
                appMenuLoader.shouldBeVisible = !appMenuLoader.shouldBeVisible;
            } else {
                appMenuLoader.shouldBeVisible = !appMenuLoader.shouldBeVisible;
            }
        }
    }
}
