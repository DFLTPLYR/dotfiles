import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

    property bool shouldBeVisible: false
    property real animProgress: 0

    GlobalShortcut {
        name: "showSettingsPanel"
        description: "Show Settings Panel"

        onPressed: {
            if (root.shouldBeVisible) {
                root.shouldBeVisible = false;
                root.animProgress = 0;
                return;
            }
            root.shouldBeVisible = true;
            root.animProgress = root.shouldBeVisible ? 1 : 0;
        }
    }

    Loader {
        active: root.shouldBeVisible
        sourceComponent: SettingPanel {}
    }

    component SettingPanel: FloatingWindow {
        id: floatingPanel

        property bool isPortrait: screen.height > screen.width

        color: Qt.rgba(0.33, 0.33, 0.41, 0.78)
        minimumSize: Qt.size(screen.width / 2, screen.height / 1.5)
        maximumSize: Qt.size(screen.width / 2, screen.height / 1.5)

        ColumnLayout {
            anchors.fill: parent

            Item {
                Layout.fillWidth: true

                Layout.preferredHeight: screen.height * 0.2
                Layout.margins: 10

                Rectangle {
                    anchors.fill: parent
                    color: "lightgray"
                    radius: 10

                    Text {
                        anchors.centerIn: parent
                        text: "Settings Panel Content"
                        font.pixelSize: 24
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 10

                TabBar {
                    id: tabBar
                    Layout.fillWidth: true
                    TabButton {
                        text: qsTr("Navbar")
                    }
                    TabButton {
                        text: qsTr("Extra Navbar")
                    }
                    TabButton {
                        text: qsTr("Sidebar")
                    }
                    TabButton {
                        text: qsTr("App Menu")
                    }
                    TabButton {
                        text: qsTr("Wallpaper Menu")
                    }
                    TabButton {
                        text: qsTr("Clipboard")
                    }
                }

                StackLayout {
                    id: contentLayout
                    currentIndex: tabBar.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Todo: replace with actual settings components

                    Text {
                        anchors.centerIn: parent
                        text: "Additional Settings Here"
                        font.pixelSize: 18
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "2"
                        font.pixelSize: 18
                    }
                }
            }
        }
    }
}
