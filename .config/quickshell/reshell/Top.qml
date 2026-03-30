import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.core
import qs.modules

PanelWindow {
    id: panel

    color: "transparent"

    anchors {
        top: fileView.adapter.position === "top"
        bottom: fileView.adapter.position === "bottom"
        left: fileView.adapter.position === "left"
        right: fileView.adapter.position === "right"
    }

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusiveZone: fileView.adapter.side ? navbar.width : navbar.height
    exclusionMode: ExclusionMode.Normal

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: `Top-${screen.name}`

    mask: Region {
        item: navbar
    }

    Navbar {
        id: navbar
    }
}
