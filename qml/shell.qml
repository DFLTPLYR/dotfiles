import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Quickshell

import qs.components

ShellRoot {
    FloatingWindow {
        title: 'test'
        minimumSize: Qt.size(screen.width / 4, screen.height / 6)
        color: 'transparent'

        NotificationPanel {
            anchors.fill: parent
        }
    }
}
