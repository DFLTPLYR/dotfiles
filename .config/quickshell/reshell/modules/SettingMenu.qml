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
        width: Math.min(0.20 * settingpanel.width, 150)
        height: settingpanel.height
        focus: true
        background: Rectangle {
            anchors.fill: parent
            color: Colors.setOpacity(Colors.color.background, 0.5)
        }

        DelegateModel {
            id: navModel
            model: ListModel {
                id: navList
                ListElement {
                    name: "Property"
                    page: 0
                }
                ListElement {
                    name: "Wallpaper"
                    page: 1
                }
            }

            delegate: Button {
                required property string name
                required property int page
                width: ListView.view.width
                text: name
                onClicked: {
                    contentContainer.currentIndex = page;
                }
            }
        }

        ListView {
            anchors.fill: parent
            model: navModel
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
