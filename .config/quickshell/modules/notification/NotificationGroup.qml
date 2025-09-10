import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Quickshell

import qs.utils
import qs.assets

Item {
    id: layered
    opacity: 1
    property bool open: false
    property real dragStartX: 0
    property int gap: 3
    required property var group
    required property var notifications
    layer.enabled: true
    height: layered.open ? notifications.length * (60 + gap) : Math.min(3, notifications.length) * gap + 60
    width: parent.width

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
            color: Scripts.setOpacity(Assets.color10, 0.4)
            layer.enabled: true
            height: 60
            width: Math.round(parent.width)
            y: layered.open ? index * (60 + gap) : index * 5
            x: (parent.width - width) / 2

            radius: 10

            scale: layered.open ? 1 : (parent.width - (index * 10)) / parent.width
            opacity: layered.open || index < 3 ? 1 : 0

            Rectangle {
                id: imageWrapper
                property var iconPath: modelData.image || Quickshell.iconPath(modelData.appIcon, true)
                visible: !!iconPath
                anchors.left: parent.left
                anchors.leftMargin: 2
                opacity: layered.open || index < 1 ? 1 : 0.5
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height * 0.9
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
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Rectangle {
                anchors {
                    left: imageWrapper.right ?? parent.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width - imageWrapper.width
                height: parent.height
                opacity: layered.open || index < 1 ? 1 : 0
                bottomRightRadius: delegateRect.radius
                topRightRadius: delegateRect.radius
                color: "transparent"

                Text {
                    text: modelData.summary
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 10
                    font.bold: true
                    color: Assets.color14
                    width: Math.round(parent.width - 20)
                    font.family: FontAssets.fontSometypeItalic
                    elide: Text.ElideRight
                }

                Text {
                    text: modelData.body
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 10
                    font.pixelSize: 12
                    color: Assets.color14
                    elide: Text.ElideRight
                    width: Math.round(parent.width - 20)
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
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

            Behavior on scale {
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
            Behavior on x {
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
                    } else {
                        delegateRect.x = (parent.width - width) / 2;
                    }
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
