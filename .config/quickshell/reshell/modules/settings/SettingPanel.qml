pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Qt.labs.StyleKit
import qs.core
import qs.core.theme
import qs.modules.settings.page

ApplicationWindow {
    id: floatingwindow

    title: "Settings"
    property int page: 0

    RowLayout {
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
                readonly property bool isActive: ListView.isCurrentItem || navma.containsMouse

                clip: true
                width: ListView.view.width
                height: 40
                color: Colors.setOpacity(delegateRoot.isActive ? Qt.darker(Colors.theme.surface, 1.5) : Colors.theme.surface, 0.5)
                radius: delegateRoot.isActive ? 10 : 0

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

        // NotificationPage
        NotificationPage {}

        // BackgroundPage
        BackgroundPage {}

        // TestPage
        TestPage {}
    }
}
