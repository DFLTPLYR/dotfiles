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

        // Item {
        //     id: layercontainer
        //     width: panel.screen.width
        //     height: panel.screen.height
        //     Instantiator {
        //         model: ScriptModel {
        //             values: [...Wallpaper.config.source].filter(item => item.screens.some(s => s.name === panel.screen.name))
        //         }
        //         delegate: Image {
        //             required property var modelData
        //             property var pos: modelData.screens.find(s => s.name === panel.screen.name)
        //             width: pos.width
        //             height: pos.height
        //             x: pos ? pos.posX : 0
        //             y: pos ? pos.posY : 0
        //             source: modelData.source
        //             parent: layercontainer
        //             visible: !!pos
        //         }
        //     }
        // }
    }
}
