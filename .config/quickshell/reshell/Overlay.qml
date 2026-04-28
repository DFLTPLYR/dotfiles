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
        regions: [
            Region {
                item: volumeSlider
            },
            Region {
                item: notification.contentItem
            }
        ]
    }

    Notifications {
        id: notification
    }

    VolumeSlider {
        id: volumeSlider
    }
}
