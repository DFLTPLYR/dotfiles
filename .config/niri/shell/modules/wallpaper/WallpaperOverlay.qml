pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.config
import Qt.labs.folderlistmodel

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root
        property bool isVisible: false
        property ShellScreen modelData
        readonly property bool isPortrait: screen.height > screen.width
        signal toggle

        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        screen: modelData
        color: "transparent"

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            clip: true
            source: {
                let wallpaper = Config.wallpaper.find(m => m.monitor === screen.name);
                if (!wallpaper || wallpaper.path === null) {
                    return "";
                }
                return Qt.resolvedUrl(Quickshell.env("HOME") + wallpaper.path);
            }
        }

        PopupWindow {
            id: popupWindow
            property bool shouldBeVisible: false
            property bool internalVisible: false
            property real animProgress: 0.0

            implicitWidth: contentRect.width
            implicitHeight: contentRect.height
            color: "transparent"

            visible: internalVisible

            // Manual animator
            NumberAnimation on animProgress {
                id: anim
                duration: 300
                easing.type: Easing.InOutQuad
            }

            Rectangle {
                id: contentRect
                width: 400
                height: 300
            }

            onShouldBeVisibleChanged: {
                const target = shouldBeVisible ? 1.0 : 0.0;
                if (anim.to !== target || !anim.running) {
                    anim.to = target;
                    anim.restart();
                }
            }

            onAnimProgressChanged: {
                if (animProgress > 0 && !internalVisible) {
                    internalVisible = true;
                } else if (!shouldBeVisible && animProgress === 0.00) {
                    internalVisible = false;
                    root.isVisible = false;
                }
            }

            anchor {
                window: root
                rect {
                    x: {
                        if (Config.navbar.position === "right") {
                            return -parentWindow.width + parentWindow.width;
                        } else if (Config.navbar.position === "left") {
                            return parentWindow.width;
                        } else {
                            return Math.round((parentWindow.width - width) * (Config.navbar.popup.x / 100));
                        }
                    }

                    y: {
                        if (Config.navbar.position === "top") {
                            return parentWindow.height;
                        } else if (Config.navbar.position === "bottom") {
                            return -parentWindow.height + parentWindow.height;
                        } else {
                            return Math.round((parentWindow.height - height) * Config.navbar.popup.y / 100);
                        }
                    }
                }
                adjustment: PopupAdjustment.All
            }

            Connections {
                target: root
                function onToggle() {
                    if (root.screen.name === Config.focusedMonitor?.name) {
                        popupWindow.shouldBeVisible = !popupWindow.shouldBeVisible;
                    } else {
                        popupWindow.shouldBeVisible = false;
                    }
                }
            }
        }

        Connections {
            target: Config
            function onOpenWallpaperPickerChanged() {
                root.isVisible = true;
                root.toggle();
            }
        }

        Component.onCompleted: {
            var exists = false;
            for (var i = 0; i < Config.wallpaper.length; i++) {
                if (Config.wallpaper[i].monitor === modelData.name) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                Config.wallpaper.push({
                    monitor: modelData.name,
                    path: null
                });
            }
            if (this.WlrLayershell) {
                this.exclusionMode = ExclusionMode.Ignore;
                this.WlrLayershell.layer = WlrLayer.Background;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
            }
        }
    }
}
