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
        component: RowLayout {
            anchors.fill: parent
            spacing: 0

            SideBar {
                Layout.preferredWidth: Math.min(0.20 * floatingwindow.width, 200)
                Layout.fillHeight: true
                onChangePage: page => {
                    floatingwindow.page = page;
                }
            }

            Content {
                id: content
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: floatingwindow.page
            }

            Component.onCompleted: floatingwindow.data.push(this)
        }
    }

    component SideBar: Item {
        id: sidebar
        signal changePage(int i)

        DelegateModel {
            id: navModel
            model: Global.settings
            delegate: Rectangle {
                id: model
                required property string name
                required property int page
                readonly property bool isActive: floatingwindow.page === model.page
                clip: true
                width: ListView.view.width
                height: 40
                color: Colors.setOpacity((navma.containsMouse || model.page === floatingwindow.page) ? Qt.darker(Colors.theme.surface, 1.5) : Colors.theme.surface, 0.5)
                radius: (model.isActive || navma.containsMouse) ? 10 : 0

                Behavior on radius {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on color {
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
            anchors {
                fill: parent
                margins: 10
            }
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
