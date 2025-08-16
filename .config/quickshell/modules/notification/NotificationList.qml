pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs
import qs.utils
import qs.services

Scope {
    id: notificationPopup
    property ListModel notificationListModel: ListModel {}

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
            property bool shouldBeVisible: true

            visible: shouldBeVisible
            width: parent.width
            height: parent.height

            spacing: 10

            model: notificationPopup.notificationListModel

            delegate: NotificationItem {}

            add: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 250
                }
                NumberAnimation {
                    property: "x"
                    from: 200
                    to: 0
                    duration: 250
                }
            }

            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 250
                }
                NumberAnimation {
                    property: "x"
                    to: 200
                    duration: 250
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 250
                }
            }

            Connections {
                target: GlobalState
                function onShowMprisChangedSignal() {
                    listview.shouldBeVisible = !listview.shouldBeVisible;
                }
            }
        }
    }

    Connections {
        target: NotificationService
        function onNotify(notif) {
            notificationPopup.notificationListModel.append({
                notificationId: notif.notificationId,
                actions: notif.actions,
                appIcon: notif.appIcon,
                appName: notif.appName,
                body: notif.body,
                image: notif.image,
                summary: notif.summary,
                time: notif.time,
                urgency: notif.urgency
            });
        }
        function onTimeout(id) {
            for (var i = 0; i < notificationPopup.notificationListModel.count; ++i) {
                if (notificationPopup.notificationListModel.get(i).notificationId === id) {
                    notificationPopup.notificationListModel.remove(i);
                    break;
                }
            }
        }
    }
}
