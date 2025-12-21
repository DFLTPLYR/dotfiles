import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.config

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
            source: root.isPortrait ? "file:///home/dfltplyr/Pictures/wallpaper/portrait/purple-girl.jpg" : "file:///home/dfltplyr/Pictures/wallpaper/landscape/1920x1080.jpg"
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
