import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import Quickshell

import qs.utils
import qs.services
import qs.components
import qs.animations
import qs.modules.notification

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    color: 'transparent'

    property bool isEmpty: NotificationService.list.length > 0
    property ListModel notificationGroup: ListModel {}

    ColumnLayout {
        id: container
        anchors.fill: parent
        clip: true

        StyledButton {
            icon: "\uf1f8"
            visible: root.isEmpty
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight
            size: 24
            iconRatio: 0.5
            borderColor: Colors.color10
            backgroundColor: Scripts.setOpacity(Colors.background, 0.4)
            hoverColor: Scripts.setOpacity(Colors.color15, 0.7)
            iconColor: Colors.color10
            onClicked: {
                NotificationService.discardAllNotifications();
                root.notificationGroup.clear();
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10

            model: root.notificationGroup

            delegate: Rectangle {
                id: delegateRect

                property real dragStartX: 0
                property bool expand: false
                property int collapsedHeight: 40
                property int expandedHeight: notificationItem.height

                height: expand ? expandedHeight + 10 : collapsedHeight
                implicitWidth: container.width

                color: Scripts.setOpacity(Colors.background, 0.7)

                border.color: Colors.color1
                radius: 8
                clip: true

                Behavior on height {
                    AnimatedNumber {}
                }

                ColumnLayout {
                    id: notificationItem
                    width: Math.round(parent.width * 0.95)

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    spacing: 8

                    RowLayout {
                        visible: !delegateRect.expand
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            visible: appIcon
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24

                            color: "transparent"
                            clip: true

                            Image {
                                id: image
                                anchors.fill: parent
                                source: Quickshell.iconPath(appIcon, "image-missing")
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 5

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Text {
                                    text: appName
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    color: Colors.color12
                                }

                                Text {
                                    id: timeText
                                    text: Qt.formatDateTime(new Date(time), "hh:mm AP")
                                    color: Colors.color11
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Repeater {
                            model: notifications
                            delegate: NotificationItem {
                                implicitWidth: parent.width
                                visible: delegateRect.expand
                            }
                        }
                    }
                }

                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: delegateRect
                    drag.axis: Drag.XAxis
                    onClicked: {
                        delegateRect.expand = !delegateRect.expand;
                    }
                    onPressed: {
                        delegateRect.dragStartX = delegateRect.x;
                    }
                    onReleased: {
                        if (Math.abs(delegateRect.x) > parent.width * 0.3) {
                            for (var i = 0; i < notifications.count; ++i) {
                                var item = notifications.get(i);
                                NotificationService.discardNotification(item.notificationId);
                            }
                            root.notificationGroup.remove(index);
                        }
                        delegateRect.x = 0;
                    }
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
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 250
                }
                NumberAnimation {
                    property: "x"
                    from: 0
                    to: 300
                    duration: 250
                }
            }

            displaced: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 250
                }
            }

            footer: Item {
                width: container.width
                height: !root.isEmpty ? container.height : 0

                Text {
                    anchors.centerIn: parent
                    text: " No notifications \uf0f3"
                    visible: NotificationService.list.length === 0
                    color: Colors.color10
                    font.pixelSize: 16
                }
            }
        }
    }

    function findGroupIndexByApp(appName) {
        for (var i = 0; i < root.notificationGroup.count; ++i) {
            var g = root.notificationGroup.get(i);
            if (g.appName === appName)
                return i;
        }
        return -1;
    }

    function sanitizeNotif(n) {
        return {
            notificationId: n.notificationId || 0,
            actions: n.actions || [],
            appIcon: n.appIcon || "",
            appName: n.appName || "",
            body: n.body || "",
            image: n.image || "",
            summary: n.summary || "",
            time: n.time || Date.now(),
            urgency: n.urgency || "normal"
        };
    }

    Connections {
        target: NotificationService
        function onNotify(notif) {
            var notification = sanitizeNotif(notif);
            var groupIndex = findGroupIndexByApp(notification.appName);

            if (groupIndex !== -1) {
                var group = root.notificationGroup.get(groupIndex);
                var notifs = group.notifications || [];
                notifs.insert(0, notification);
            } else {
                root.notificationGroup.append({
                    appName: notification.appName,
                    appIcon: notification.appIcon,
                    notifications: [notification],
                    time: notification.time
                });
            }
        }
    }

    Component.onCompleted: {
        root.notificationGroup.clear();
        for (var appName in NotificationService.groupsByAppName) {
            var group = NotificationService.groupsByAppName[appName];

            var notifs = [];
            for (var i = 0; i < group.notifications.length; ++i) {
                var notif = group.notifications[i];
                notifs.push({
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

            notifs.sort(function (a, b) {
                return b.time - a.time;
            });

            root.notificationGroup.append({
                appName: group.appName,
                appIcon: group.appIcon,
                notifications: notifs,
                time: group.time
            });
        }
    }
}
