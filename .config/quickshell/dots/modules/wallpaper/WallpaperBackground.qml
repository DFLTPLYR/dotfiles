import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.config

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen modelData
        readonly property string filePath: Config.general.wallpapers.find(wallpaperItem => wallpaperItem && wallpaperItem.monitor === screen.name)?.path || ""
        readonly property string tempPath: Config.general.previewWallpaper.find(wallpaperItem => wallpaperItem && wallpaperItem.monitor === screen.name)?.path || ""
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
            id: main
            height: parent.height
            width: parent.width
            sourceSize.width: screen.width
            sourceSize.height: screen.height
            fillMode: Image.PreserveAspectCrop
            source: {
                if (filePath === undefined) {
                    return "";
                }
                return Qt.resolvedUrl(filePath);
            }
        }

        Image {
            id: testMage
            fillMode: Image.PreserveAspectFit
            width: sourceSize.width
            height: sourceSize.height
            source: Config.general.customWallpaper?.[0]?.path?.path ? Qt.resolvedUrl(Config.general.customWallpaper?.[0]?.path?.path) : ""
            x: {
                var found = Config.general.customWallpaper?.[0]?.monitors?.find(s => s && s.name === screen.name);
                return found?.x * 4;
            }
            y: {
                var found = Config.general.customWallpaper?.[0]?.monitors?.find(s => s && s.name === screen.name);
                return found?.y * 4;
            }
        }

        Image {
            id: temp
            width: screen.width
            height: screen.height
            fillMode: Image.PreserveAspectCrop
            source: {
                if (tempPath === undefined) {
                    return "";
                }
                return Qt.resolvedUrl(tempPath);
            }

            onSourceChanged: {
                fadeIn.running = true;
            }

            PropertyAnimation {
                id: fadeIn
                target: temp
                duration: 300
                properties: "opacity"
                from: 0
                to: 1
            }
        }

        Rectangle {
            visible: !filePath && !tempPath
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
