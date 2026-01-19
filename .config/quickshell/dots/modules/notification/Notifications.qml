import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

Scope {
    id: root
    property ListModel notificationListModel: ListModel {}

    PanelWindow {
        WlrLayershell.namespace: "notifications"
        screen: Quickshell.screens.find(s => s.name === Config.focusedMonitor?.name) ?? null
        property bool isPortrait: screen.height > screen.width
        implicitWidth: isPortrait ? Math.round(screen.width / 2.5) : Math.round(screen.width / 5)
        color: "transparent"

        mask: Region {
            item: listview.contentItem
        }

        anchors {
            top: true
            right: true
            bottom: true
        }

        ListView {
            id: listview

            model: root.notificationListModel
            width: parent.width
            height: parent.height

            spacing: 10
            topMargin: 10
            leftMargin: 20
            rightMargin: 20

            delegate: StyledRect {
                required property var modelData
                color: Qt.rgba(0, 0, 0, 0.8)
                width: parent ? parent.width : 0
                height: 60

                RowLayout {
                    anchors.fill: parent

                    // icon
                    Rectangle {
                        visible: modelData.appIcon || modelData.image
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        Layout.margins: 2
                        color: "transparent"
                        clip: true
                        Image {
                            id: notificationIcon
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: Qt.resolvedUrl(modelData.image || modelData.appIcon)
                        }
                    }
                    // content
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 2
                        spacing: 2
                        Text {
                            text: modelData.appName
                            font.bold: true
                            font.pointSize: 12
                            color: "white"
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.summary
                            font.pointSize: 10
                            color: "white"
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.body
                            font.pointSize: 9
                            color: "lightgray"
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        NotificationServer.timeoutNotification(modelData.notificationId);
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
        }

        Connections {
            target: NotificationServer
            function onNotify(notif) {
                root.notificationListModel.append({
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
                for (var i = 0; i < root.notificationListModel.count; ++i) {
                    if (root.notificationListModel.get(i).notificationId === id) {
                        root.notificationListModel.remove(i);
                        break;
                    }
                }
            }
            function onDiscardAll() {
                root.notificationListModel.clear();
            }
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
