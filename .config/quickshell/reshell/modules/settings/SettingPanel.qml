pragma ComponentBehavior: Bound
import Quickshell

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

FloatingWindow {
    id: floatingwindow
    property int page: 0
    title: "Settings"
    minimumSize: Qt.size(floatingwindow.screen.width / 2, floatingwindow.screen.height / 2)
    maximumSize: Qt.size(floatingwindow.screen.width, floatingwindow.screen.height)
    color: Colors.theme.surface

    Behavior on color {
        ColorAnimation {
            duration: 300
            easing: Easing.InOutQuad
        }
    }

    LazyLoader {
        active: floatingwindow.visible
        component: RowLayout {
            anchors.fill: parent
            spacing: 0

            Pane {
                Layout.preferredWidth: Math.min(0.20 * floatingwindow.width, 120)
                Layout.fillHeight: true

                DelegateModel {
                    id: navModel
                    model: Global.settings
                    delegate: Pane {
                        required property string name
                        required property int page
                        clip: true
                        width: ListView.view.width
                        height: 40
                        bg.color: Colors.setOpacity(navma.containsMouse ? Qt.darker(Colors.theme.surface, 1.5) : Colors.theme.surface, 0.5)

                        Behavior on bg.color {
                            ColorAnimation {
                                duration: 300
                                easing: Easing.InOutQuad
                            }
                        }

                        Text {
                            text: name
                            leftPadding: 10
                            height: parent.height
                            color: Colors.theme.on_surface
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
                currentIndex: floatingwindow.page
                Layout.fillWidth: true
                Layout.fillHeight: true

                // General Page
                GeneralPage {
                    screen: floatingwindow.screen
                }

                // ComponentsPage
                ComponentsPage {}

                // BackgroundPage
                BackgroundPage {}
            }
            Component.onCompleted: floatingwindow.data.push(this)
        }
    }

    Component.onDestruction: Global.save()
}
