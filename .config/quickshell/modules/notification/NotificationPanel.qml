import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell

import qs.assets
import qs.utils

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 10
    color: Scripts.setOpacity(Assets.background, 0.5)

    ScrollView {
        ScrollBar.vertical: ScrollBar {}
        anchors.fill: parent
        anchors.margins: 10

        Column {
            width: parent.width

            Repeater {
                model: NotificationService.appNameList
                delegate: NotificationGroup {
                    required property var modelData
                    width: parent.width
                    notifications: NotificationService.groupsByAppName[modelData].notifications
                }
            }
        }
    }
}
