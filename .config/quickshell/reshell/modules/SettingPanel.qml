import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.core
import qs.components
import qs.modules.pages

FloatingWindow {
    id: settingpanel
    property int page: 0
    screen: panel.screen
    title: "Reshell"
    color: Colors.setOpacity(Colors.color.background, 0.5)

    visible: Compositor.focusedWindow === screen.name && Global.edit

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)

    Loader {
        anchors.fill: parent
        active: settingpanel.visible
        sourceComponent: RowLayout {
            Rectangle {
                Layout.preferredWidth: Math.min(0.20 * settingpanel.width, 120)
                Layout.fillHeight: true

                color: Colors.setOpacity(Colors.color.background, 0.5)

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
                    width: parent.width
                    height: contentHeight
                    model: navModel
                }
            }

            StackLayout {
                id: contentContainer
                currentIndex: settingpanel.page
                Layout.fillWidth: true
                Layout.fillHeight: true

                Pane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    background: Rectangle {
                        anchors.fill: parent
                        color: Colors.setOpacity(Colors.color.background, 0.5)
                    }
                }

                // WallpaperPage
                WallpaperPage {}
            }
        }
    }
}
