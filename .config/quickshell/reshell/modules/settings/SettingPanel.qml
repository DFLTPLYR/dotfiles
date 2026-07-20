pragma ComponentBehavior: Bound
import Quickshell

import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings.page

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
            spacing: 5

            SideBar {
                Layout.preferredWidth: Math.min(0.20 * floatingwindow.width, 150)
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
                id: delegateRoot
                required property string name
                required property int page
                readonly property bool isActive: ListView.isCurrentItem
                clip: true
                width: ListView.view.width
                height: 40
                color: Colors.setOpacity((navma.containsMouse || delegateRoot.isActive) ? Qt.darker(Colors.theme.surface, 1.5) : Colors.theme.surface, 0.5)
                radius: (delegateRoot.isActive || navma.containsMouse) ? 10 : 0
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
                    text: delegateRoot.name
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
                        sidebar.changePage(delegateRoot.page);
                    }
                }
            }
        }

        ListView {
            id: navList
            anchors {
                fill: parent
                margins: 5
            }
            spacing: 2
            model: navModel
            currentIndex: floatingwindow.page
        }
    }

    component Content: StackLayout {
        id: contentContainer
        currentIndex: floatingwindow.page

        // General Page
        GeneralPage {}

        // ComponentsPage
        ComponentsPage {}

        // BackgroundPage
        BackgroundPage {}
    }

    onWindowConnected: paneLoader.active = true
    onClosed: Global.save()
}
