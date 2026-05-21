pragma ComponentBehavior: Bound
import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.core
import qs.modules

PanelWindow {
    id: panel
    color: "transparent"

    implicitHeight: screen.height
    implicitWidth: screen.width

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: `Overlay-${screen.name}`

    mask: Region {
        regions: []
    }

    Notifications {
        id: notification
        Component.onCompleted: {
            const reg = Components.createRegion();
            panel.mask.regions.push(reg);
        }
    }

    VolumeSlider {
        id: volumeSlider
        Component.onCompleted: {
            const reg = Components.createRegion();
            panel.mask.regions.push(reg);
        }
    }
}
