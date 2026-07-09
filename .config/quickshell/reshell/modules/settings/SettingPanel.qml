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
        id: paneLoader
        RowLayout {
            anchors.fill: parent
            spacing: 0

            SideBar {
                Layout.preferredWidth: Math.min(0.20 * floatingwindow.width, 120)
                Layout.fillHeight: true
                onChangePage: page => {
                    content.currentIndex = page;
                }
            }

            Content {
                id: content
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Component.onCompleted: floatingwindow.data.push(this)
        }
    }

    component SideBar: Pane {
        id: sidebar
        signal changePage(int i)
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
                        sidebar.changePage(page);
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

    component Content: StackLayout {
        id: contentContainer
        currentIndex: floatingwindow.page

        // General Page
        GeneralPage {
            screen: floatingwindow.screen
        }

        // ComponentsPage
        ComponentsPage {}

        // BackgroundPage
        BackgroundPage {}
    }

    onWindowConnected: paneLoader.active = true
    onClosed: Global.save()
}
