import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

import qs.services
import qs.assets

Scope {
    id: root

    LazyLoader {
        active: false
        component: PanelWindow {
            screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null
            implicitWidth: container.width
            color: 'transparent'

            mask: Region {
                item: container
            }

            anchors {
                top: true
                right: true
                bottom: true
            }

            margins {
                top: Math.round(height / 4)
                right: 10
                bottom: Math.round(height / 4)
            }

            Rectangle {
                id: container
                height: parent.height
                width: Math.min(500, screen.width / 2)
                color: 'transparent'
            }

            // set up
            Component.onCompleted: {
                if (this.WlrLayershell != null) {
                    this.WlrLayershell.layer = WlrLayer.Overlay;
                    this.exclusiveZone = 0;
                }
            }
        }
    }
}
