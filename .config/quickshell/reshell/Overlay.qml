import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.modules

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        screen: modelData

        color: "transparent"

        implicitHeight: screen.height
        implicitWidth: screen.width

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: `Overlay-${screen.name}`

        mask: Region {
            regions: [
                Region {
                    item: null
                }
            ]
        }

        Notifications {
            id: notification
            width: 400
            height: panel.height
            x: (panel.width * 1) - width
        }
    }
}
