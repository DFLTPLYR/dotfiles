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
        regions: [
            Region {
                item: settingloader.item
            },
            Region {
                item: navbar
            }
        ]
    }

    Navbar {
        id: navbar
    }

    Loader {
        id: settingloader
        active: false
        sourceComponent: Settings {}

        property bool shouldShow: Global.enableSetting && Compositor.focusedMonitor === screen.name

        Connections {
            target: settingloader.item
            enabled: settingloader.item !== null
            function onStateChanged() {
                if (settingloader.item.state === 'hide') {
                    settingloader.active = false;
                }
            }
        }

        onShouldShowChanged: {
            if (shouldShow) {
                active = true;
            } else if (item) {
                item.state = 'hide';
            }
        }

        onLoaded: {
            item.state = 'show';
        }
    }
}
