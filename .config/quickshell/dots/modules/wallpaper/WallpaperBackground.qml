import QtQuick
import Quickshell
import Quickshell.Wayland
import QtCore

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
            smooth: true
            mipmap: true
            antialiasing: true
            fillMode: Image.PreserveAspectCrop
            source: {
                if (filePath === undefined) {
                    return "";
                }
                return Qt.resolvedUrl(filePath);
            }
        }

        Image {
            id: customImage
            fillMode: Image.PreserveAspectFit
            visible: Config.general.useCustomWallpaper
            height: sourceSize.height
            width: sourceSize.width
            smooth: true
            mipmap: true
            antialiasing: true
            source: `${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${screen.name}.jpg`
        }

        Connections {
            target: Config
            function onReload() {
                customImage.source = "";
                customImage.visible = false;
                Qt.callLater(() => {
                    customImage.visible = true;
                    customImage.source = `${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${screen.name}.jpg`;
                }, 500);
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
            visible: !filePath && !tempPath && !Config.general.useCustomWallpaper
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
