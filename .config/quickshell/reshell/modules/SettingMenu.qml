import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.core
import qs.components
import qs.modules.pages

FloatingWindow {
    id: settingpanel
    property alias page: contentContainer.currentIndex

    title: "Reshell"
    color: Colors.setOpacity(Colors.color.background, 0.5)

    visible: Compositor.focusedWindow === screen.name && Global.edit

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)

    Drawer {
        id: drawer
        width: 0.20 * settingpanel.width
        height: settingpanel.height
        focus: true
        Label {
            text: "Content goes here!"
            anchors.centerIn: parent
        }
    }

    StackLayout {
        id: contentContainer
        anchors.fill: parent

        // property
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // WallpaperPage
        WallpaperPage {}
    }
}
