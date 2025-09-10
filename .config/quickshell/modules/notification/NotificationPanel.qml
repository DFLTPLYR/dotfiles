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

    clip: true

    ListView {
        anchors.fill: parent
        anchors.margins: 10
        ScrollBar.vertical: ScrollBar {}
        model: NotificationService.appNameList
        delegate: NotificationGroup {
            required property var modelData
            notifications: NotificationService.groupsByAppName[modelData].notifications
        }
    }
}
