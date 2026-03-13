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

        Repeater {
            model: ScriptModel {
                values: [...Wallpaper.config.layers].filter(item => item.screens.some(s => s && s.name === panel.screen.name))
            }
            delegate: Image {
                required property var modelData
                property var relative: modelData.screens.find(s => s.name === panel.screen.name)
                width: modelData.width
                height: modelData.height
                x: relative.x
                y: relative.y
                source: modelData.source
            }
        }
    }
}
