import Quickshell

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.pages

FloatingWindow {
    id: settingpanel
    property int page: 0

    title: "Reshell"
    color: Colors.setOpacity(Colors.color.background, 0.5)

    visible: Compositor.focusedWindow === screen.name && Global.edit

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)

    LazyLoader {
        active: settingpanel.visible
        component: RowLayout {
            anchors.fill: parent
            spacing: 0

            Pane {
                Layout.preferredWidth: Math.min(0.20 * settingpanel.width, 120)
                Layout.fillHeight: true
                // color: Colors.setOpacity(Colors.color.background, 0.5)

                DelegateModel {
                    id: navModel
                    model: Global.settings
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

                // General Page
                GeneralPage {}

                // ComponentsPage
                ComponentsPage {}

                // WallpaperPage
                WallpaperPage {}
            }
            Component.onCompleted: settingpanel.data.push(this)
        }
    }
}
