import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.core
import qs.modules

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        screen: modelData

        color: "transparent"

        anchors {
            top: Navbar.config.position === "top"
            bottom: Navbar.config.position === "bottom"
            left: Navbar.config.position === "left"
            right: Navbar.config.position === "right"
        }

        implicitHeight: screen.height
        implicitWidth: screen.width

        exclusiveZone: navbar.height
        exclusionMode: ExclusionMode.Normal

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: `Top-${screen.name}`

        mask: Region {
            regions: [
                Region {
                    item: Global.enableSetting ? floatingWindow : null
                },
                Region {
                    item: navbar
                }
            ]
        }

        Navbar {
            id: navbar
        }

        Settings {
            id: floatingWindow
        }
    }
}
