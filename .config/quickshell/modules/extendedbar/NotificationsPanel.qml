import QtQuick
import Quickshell

import QtQuick.Controls
import QtQuick.Layouts

import qs.utils
import qs.services
import qs.components

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    color: 'transparent'

    property bool isEmpty: NotificationService.list.length > 0

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
                onClicked: NotificationService.discardAllNotifications()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            model: NotificationService.list

            delegate: Rectangle {
                implicitWidth: container.width
                implicitHeight: notificationItem.height

                color: Scripts.setOpacity(Colors.background, 0.7)

                border.color: Colors.color1
                radius: 12
                clip: true

                RowLayout {
                    id: notificationItem
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.round(parent.width * 0.9)
                    spacing: 8

                    Rectangle {
                        visible: !!modelData.image || !!modelData.appIcon
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        Layout.fillHeight: true
                        color: "transparent"
                        clip: true

                        Image {
                            id: image
                            anchors.fill: parent
                            source: modelData.image || modelData.appIcon
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
                                text: modelData.appName
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                color: Colors.color12
                            }

                            Text {
                                id: timeText
                                text: Qt.formatDateTime(new Date(modelData.time), "hh:mm AP")
                                color: Colors.color11
                            }
                        }

                        Text {
                            text: modelData.body
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            color: Colors.color11
                        }

                        Text {
                            text: modelData.summary
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            color: Colors.color10
                        }
                    }
                }

                MouseArea {
                    id: itemArea
                    anchors.fill: parent
                    onClicked: {
                        NotificationService.discardNotification(modelData.notificationId);
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
}
