import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.core

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        readonly property var path: Wallpaper.config.source.filter(s => s && s.monitor === screen.name) || []
        screen: modelData
        color: "transparent"

        implicitHeight: screen.height
        implicitWidth: screen.width

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: `Background-${screen.name}`

        // warning
        // Rectangle {
        //     visible: path.length <= 0
        //     color: Qt.rgba(0, 0, 0, 1)
        //     width: parent.width
        //     height: parent.height
        // }

        // Basic Background
        // Repeater {
        //     model: [...panel.path]
        //     delegate: Image {
        //         id: image
        //         visible: Wallpaper.config.mode === "standard"
        //         width: panel.screen.width
        //         height: panel.screen.height
        //         sourceSize.width: panel.screen.width
        //         sourceSize.height: panel.screen.height
        //         source: modelData.path
        //         smooth: true
        //         mipmap: true
        //         antialiasing: true
        //         fillMode: Image.PreserveAspectCrop
        //     }
        // }
        Repeater {
            model: ScriptModel {
                values: [...Wallpaper.config.source].filter(item => item.screens.some(s => s.name === panel.screen.name))
            }
            delegate: Image {
                required property var modelData
                property var pos: modelData.screens.find(s => s.name === panel.screen.name)
                width: pos.width
                height: pos.height
                x: pos ? pos.posX : 0
                y: pos ? pos.posY : 0
                source: modelData.source
                visible: !!pos
            }
        }
    }
}
