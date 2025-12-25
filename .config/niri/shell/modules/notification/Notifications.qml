import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

Scope {
    PanelWindow {
        screen: Quickshell.screens.find(s => s.name === Config.focusedMonitor?.name) ?? null
        property bool isPortrait: screen.height > screen.width
        implicitWidth: isPortrait ? Math.round(screen.width / 2.5) : Math.round(screen.width / 4)
        color: "transparent"

        mask: Region {
            item: listview.contentItem
        }

        ListView {
            id: listview

            model: NotificationServer.list

            width: parent.width
            height: parent.height

            spacing: 10
            topMargin: 10
            leftMargin: 20
            rightMargin: 20

            delegate: StyledRect {
                width: parent.width
                height: 50
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
                        console.log(notificationId);
                        NotificationServer.discardNotification(notificationId);
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
                target: NotificationServer
                function onTimeout(id) {
                    console.log("Timeout notification:", id);
                    NotificationServer.discardNotification(id);
                }
                function onDiscardAll() {
                    NotificationServer.discardAllNotifications();
                }
            }
        }

        anchors {
            top: true
            right: true
            bottom: true
        }

        Component.onCompleted: {
            if (this.WlrLayershell) {
                this.exclusionMode = ExclusionMode.Normal;
                this.WlrLayershell.layer = WlrLayer.Top;
                this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None;
            }
        }
    }
}
