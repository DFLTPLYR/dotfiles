import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.core

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        readonly property string path: Wallpaper.config.source.find(s => s && s.monitor === modelData.name)?.path || ""
        screen: modelData

        color: "transparent"

        implicitHeight: screen.height
        implicitWidth: screen.width

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: `Background-${screen.name}`

        // Basic Background
        Image {
            visible: Wallpaper.config.mode === "standard"
            width: panel.screen.width
            height: panel.screen.height
            sourceSize.width: panel.screen.width
            sourceSize.height: panel.screen.height
            source: panel.path
            smooth: true
            mipmap: true
            antialiasing: true
            fillMode: Image.PreserveAspectCrop
        }
    }
}
