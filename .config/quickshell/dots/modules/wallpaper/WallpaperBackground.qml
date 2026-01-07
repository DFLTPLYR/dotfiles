import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.config

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen modelData
        screen: modelData
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "Background"

        anchors {
            top: true
            bottom: true
            right: true
            left: true
        }

        Image {
            height: parent.height
            width: parent.width
            sourceSize.width: screen.width
            sourceSize.height: screen.height
            fillMode: Image.PreserveAspectCrop
            source: {
                const filePath = Config.wallpaper.find(wallpaperItem => wallpaperItem.monitor === screen.name)?.path;
                if (filePath === undefined) {
                    return "";
                }
                return Qt.resolvedUrl(Quickshell.env("HOME") + Config.wallpaper.find(wallpaperItem => wallpaperItem.monitor === screen.name)?.path);
            }
        }

        Rectangle {
            visible: !Config.wallpaper.find(wallpaperItem => wallpaperItem.monitor === screen.name)
            height: parent.height
            width: parent.width
            color: Qt.rgba(0, 0, 0, 0.5)
            Text {
                anchors.centerIn: parent
                font.pixelSize: Math.min(screen.width, screen.height) / 20
                text: "No wallpaper set for " + screen.name
            }
        }
    }
}
