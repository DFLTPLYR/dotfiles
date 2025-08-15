import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.utils
import qs.services

Scope {
    id: notificationPopup

    PanelWindow {
        id: root
        visible: true
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

        WlrLayershell.namespace: "quickshell:notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: true
            right: true
            bottom: true
        }

        mask: Region {
            item: listview.contentItem
        }

        color: "transparent"
        implicitWidth: screen.width / 4

        ListView {
            id: listview
            width: parent.width
            height: parent.height
            spacing: 10

            model: NotificationService.list.filter(n => n.popup)

            delegate: NotificationItem {}
        }
    }
}
