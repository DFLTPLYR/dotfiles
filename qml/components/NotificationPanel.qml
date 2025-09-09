import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell

import qs.components

ScrollView {
    ScrollBar.vertical: ScrollBar {}

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
