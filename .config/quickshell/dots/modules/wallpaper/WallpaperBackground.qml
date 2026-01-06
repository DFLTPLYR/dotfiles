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
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: Qt.resolvedUrl(Quickshell.env("HOME") + Config.wallpaper.find(wallpaperItem => wallpaperItem.monitor === screen.name)?.path)
        }
    }
}
