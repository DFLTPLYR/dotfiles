pragma ComponentBehavior: Bound
import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.core
import qs.modules
import qs.modules.notifications

PanelWindow {
    id: panel
    property list<Region> regions: []
    property var config: Global.getConfig(panel.screen).adapter
    color: "transparent"

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: `Overlay-${screen.name}`

    mask: Region {
        regions: panel.regions
    }

    Notifications {
        id: notification
        config: panel.config.notification
        onAddNotif: notif => {
            const reg = Components.createRegion();
            reg.item = notif;
            panel.regions.push(reg);
        }
        onRemoveNotif: notif => {
            for (let i of panel.regions) {
                if (i.item === notif) {
                    panel.regions = [...panel.regions.filter(n => n.item !== notif)];
                    return;
                }
            }
        }
    }

    VolumeSlider {
        id: volumeSlider
        property Region region: null
        onShouldShowOsdChanged: {
            if (volumeSlider.shouldShowOsd) {
                volumeSlider.region.item = volumeSlider;
                return;
            }
            return volumeSlider.region.item = null;
        }
        Component.onCompleted: {
            const reg = Components.createRegion();
            volumeSlider.region = reg;
            panel.regions.push(reg);
        }
    }
}
