import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell

import qs.utils
import qs.services
import qs.components

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

        RowLayout {
            visible: root.isEmpty

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignRight

            StyledButton {
                icon: "\uf1f8"
                size: 24
                iconRatio: 0.5
                borderColor: Colors.color10
                backgroundColor: Scripts.setOpacity(Colors.background, 0.4)
                hoverColor: Scripts.setOpacity(Colors.color15, 0.7)
                iconColor: MprisManager.canGoPrevious ? Colors.color10 : Colors.color0
                onClicked: {
                    console.log(JSON.stringify(NotificationService.groupsByAppName));
                    console.log(JSON.stringify(NotificationService.appNameList));
                    // NotificationService.discardAllNotifications();
                }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 10

            model: root.notificationGroup

            delegate: Rectangle {
                id: delegateRect

                property real dragStartX: 0
                property bool expand: false
                property int collapsedHeight: 40
                property int expandedHeight: notificationItem.height

                height: expand ? expandedHeight : collapsedHeight
                implicitWidth: container.width

                color: Scripts.setOpacity(Colors.background, 0.7)

                border.color: Colors.color1
                radius: 12
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }

                RowLayout {
                    id: notificationItem
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.round(parent.width * 0.9)
                    spacing: 8

                    // App Icon
                    Rectangle {
                        visible: appIcon
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        Layout.fillHeight: true
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
                        Rectangle {
                            visible: delegateRect.expand
                            Layout.fillWidth: true
                            height: 90
                            color: 'white'
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
                    property: "y"
                    from: 30
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

    Connections {
        target: NotificationService
        function onNotify(notif) {
            console.log(notif);
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
            root.notificationGroup.append({
                appName: group.appName,
                appIcon: group.appIcon,
                notifications: notifs,
                time: group.time
            });
        }
    }
}
