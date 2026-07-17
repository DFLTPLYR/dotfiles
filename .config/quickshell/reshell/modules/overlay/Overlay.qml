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
        Component.onCompleted: {
            const reg = Components.createRegion();
            reg.item = notification.contentItem;
            panel.regions.push(reg);
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
