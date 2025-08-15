import QtQuick
import Quickshell

import QtQuick.Controls
import QtQuick.Layouts

import qs.services

ListView {
    Layout.fillWidth: true
    Layout.fillHeight: true

    model: NotificationService.list

    delegate: Rectangle {
        width: parent.width
        height: 30
    }
}
