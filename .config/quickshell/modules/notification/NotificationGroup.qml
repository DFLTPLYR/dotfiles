import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Quickshell

import qs.utils
import qs.assets

Item {
    id: layered
    opacity: 0.5
    property bool open: false
    property real dragStartX: 0
    property int gap: 3
    required property var group
    required property var notifications

    height: layered.open ? notifications.length * (60 + gap) : Math.min(3, notifications.length) * gap + 60
    width: parent.width

    clip: true

    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Repeater {
        model: notifications
        delegate: Rectangle {
            id: delegateRect
            property real dragStartX: 0
            color: Scripts.setOpacity(Assets.color10, 0.5)
            layer.enabled: true
            height: 60
            y: layered.open ? index * (60 + gap) : index * 5
            x: (parent.width - width) / 2

            radius: 10

            width: layered.open ? parent.width : parent.width - (index * 10)
            border.width: 1
            border.color: Scripts.setOpacity(Assets.color14, 0.9)
            opacity: layered.open || index < 3 ? 1 : 0

            Rectangle {
                id: imageWrapper
                property var iconPath: modelData.image || Quickshell.iconPath(modelData.appIcon, true)
                visible: !!iconPath

                anchors.margins: 5
                height: parent.height
                width: height

                color: "transparent"

                Image {
                    id: maskee
                    anchors.fill: parent
                    source: imageWrapper.iconPath
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: false
                }

                Rectangle {
                    id: masking
                    anchors.fill: parent
                    radius: width / 2
                    clip: true
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: maskee
                    maskSource: masking
                }
            }

            Rectangle {
                anchors {
                    left: imageWrapper.right ?? parent.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                bottomRightRadius: delegateRect.radius
                topRightRadius: delegateRect.radius
                color: Scripts.setOpacity(Assets.color10, 0.5)

                Text {
                    text: modelData.summary
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 10
                    font.bold: true
                }

                Text {
                    text: modelData.body
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    width: parent.width - 20
                }
            }

            Item {
                anchors.fill: parent
                visible: index === 0 && notifications.length > 3
                opacity: layered.open ? 0 : 1
                anchors.margins: 20

                Rectangle {
                    width: 20
                    height: 20
                    radius: 20
                    color: 'red'
                    anchors.top: parent.top
                    anchors.right: parent.right
                    Text {
                        anchors.centerIn: parent
                        text: `${notifications.length - 3}+`
                        color: 'white'
                        font.pixelSize: 10
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent

                drag.target: delegateRect
                drag.axis: Drag.XAxis

                onClicked: {
                    layered.open = !layered.open;
                }
                onPressed: {
                    delegateRect.dragStartX = delegateRect.x;
                }
                onReleased: {
                    if (Math.abs(delegateRect.x) > parent.width * 0.1) {
                        var item = notifications[index];
                        NotificationService.discardNotification(item.notificationId);
                    }
                    delegateRect.x = 0;
                }
            }
        }
    }

    MouseArea {
        id: groupDragArea
        anchors.fill: parent
        enabled: !layered.open

        drag.target: layered
        drag.axis: Drag.XAxis

        onClicked: {
            layered.open = !layered.open;
        }
        onPressed: {
            layered.dragStartX = layered.x;
        }
        onReleased: {
            if (Math.abs(layered.x) > parent.width * 0.1) {
                NotificationService.discardNotificationGroup(layered.group);
            }
            layered.x = 0;
        }
    }
}
