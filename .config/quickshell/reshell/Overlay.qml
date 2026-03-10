import QtQuick

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import qs.core
import qs.modules
import qs.components

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        property bool shouldShowOsd: false
        property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0

        screen: modelData

        color: "transparent"

        implicitHeight: screen.height
        implicitWidth: screen.width

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: `Overlay-${screen.name}`

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        Connections {
            target: Pipewire?.defaultAudioSink?.audio || null
            function onVolumeChanged() {
                panel.shouldShowOsd = true;
                hideTimer.restart();
                panel.volume = Pipewire.defaultAudioSink?.audio.volume ?? 0;
            }
        }

        Timer {
            id: hideTimer
            interval: 1000
            onTriggered: panel.shouldShowOsd = false
        }

        Behavior on volume {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        mask: Region {
            regions: [
                Region {
                    item: volume
                },
                Region {
                    item: notifications.contentItem
                }
            ]
        }

        Notifications {
            id: notification
            width: 400
            height: panel.height
            x: (panel.width * 1) - width
        }

        // Volume Slider
        Slider {
            id: volume
            visible: panel.shouldShowOsd && Compositor.focusedMonitor === screen.name
            opacity: panel.shouldShowOsd ? 1 : 0
            from: 0
            to: 1
            value: Pipewire.defaultAudioSink?.audio.volume ?? 0
            stepSize: 0.01
            x: panel.width / 2 - width / 2

            hoverEnabled: true

            onActiveFocusChanged: {
                if (!activeFocus)
                    hideTimer.start();
            }

            onHoveredChanged: {
                if (hovered) {
                    panel.shouldShowOsd = true;
                    hideTimer.stop();
                } else {
                    hideTimer.start();
                }
            }

            onValueChanged: {
                if (Pipewire.defaultAudioSink?.audio) {
                    Pipewire.defaultAudioSink.audio.volume = value;
                }
                panel.volume = value;
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // Notifications
        ListView {
            id: notifications
            property ListModel list: ListModel {}
            visible: Compositor.focusedMonitor === screen.name
            opacity: Compositor.focusedMonitor === screen.name ? 1 : 0
            model: notifications.list
            width: 400
            height: screen.height
            x: parent.width - width
            spacing: 2
            delegate: Rectangle {
                width: notifications.width
                height: 50
                color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
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
                id: removeTransition
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

                onRunningChanged: {
                    if (!running && removeTransition.targetItem) {
                        let notificationId = removeTransition.targetItem.notificationId;
                        Notification.discardNotification(notificationId);
                    }
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 250
                }
            }
            Connections {
                target: Notifications
                function onNotify(notif) {
                    notifications.list.append({
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
                    for (var i = 0; i < notifications.list.count; ++i) {
                        if (notifications.list.get(i).notificationId === id) {
                            notifications.list.remove(i);
                            break;
                        }
                    }
                }
                function onDiscardAll() {
                    notifications.list.clear();
                }
            }
        }
    }
}
