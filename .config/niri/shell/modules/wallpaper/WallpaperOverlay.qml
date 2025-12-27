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
        property ShellScreen modelData
        readonly property bool isPortrait: screen.height > screen.width

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
                if (Config.wallpaper.find(m => m.monitor === screen.name)?.path === null) {
                    return null;
                } else {
                    return Qt.resolvedUrl(Quickshell.env("HOME") + Config.wallpaper.find(m => m.monitor === screen.name)?.path);
                }
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
