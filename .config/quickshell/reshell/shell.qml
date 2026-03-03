import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.core
import qs.modules

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: panel
            required property ShellScreen modelData
            screen: modelData

            color: "transparent"

            anchors {
                top: true
                bottom: false
                right: false
                left: false
            }

            implicitHeight: screen.height
            implicitWidth: screen.width

            exclusiveZone: navbar.height
            exclusionMode: ExclusionMode.Normal

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: `panel-${screen.name}`

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
}
