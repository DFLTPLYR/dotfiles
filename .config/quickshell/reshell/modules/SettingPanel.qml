pragma ComponentBehavior: Bound
import Quickshell

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.pages

FloatingWindow {
    id: settingpanel
    property int page: 0

    title: "Settings"
    color: Colors.setOpacity(Colors.color.background, 0.5)

    LazyLoader {
        active: settingpanel.visible
        component: RowLayout {
            anchors.fill: parent
            spacing: 0

            Pane {
                Layout.preferredWidth: Math.min(0.20 * settingpanel.width, 120)
                Layout.fillHeight: true

                DelegateModel {
                    id: navModel
                    model: Global.settings
                    delegate: Pane {
                        required property string name
                        required property int page
                        width: ListView.view.width
                        height: 40
                        bg.color: navma.containsMouse ? Qt.darker(Colors.theme.hover, 1.5) : Colors.theme.hover

                        Behavior on bg.color {
                            ColorAnimation {
                                duration: 300
                            }
                        }

                        Text {
                            text: name
                            height: parent.height
                            horizontalAlignment: Text.AlignVCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        MouseArea {
                            id: navma
                            hoverEnabled: true
                            anchors.fill: parent

                            onClicked: {
                                contentContainer.currentIndex = page;
                            }
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
                GeneralPage {
                    screen: settingpanel.screen
                }

                // ComponentsPage
                ComponentsPage {}

                // BackgroundPage
                BackgroundPage {}
            }
            Component.onCompleted: settingpanel.data.push(this)
        }
    }
}
