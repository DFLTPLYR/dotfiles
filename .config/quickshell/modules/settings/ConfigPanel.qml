pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import qs.modules.settings
import qs.components
import qs.config
import qs.utils

Scope {
    id: root

    property bool shouldBeVisible: false
    property real animProgress: 0

    GlobalShortcut {
        name: "showSettingsPanel"
        description: "Show Settings Panel"

        onPressed: root.toggle()
    }

    function toggle() {
        if (root.shouldBeVisible) {
            root.shouldBeVisible = false;
            root.animProgress = 0;
            return;
        }
        root.shouldBeVisible = true;
        root.animProgress = root.shouldBeVisible ? 1 : 0;
    }

    Loader {
        active: root.shouldBeVisible
        sourceComponent: SettingPanel {}
    }

    component SettingPanel: FloatingWindow {
        id: floatingPanel

        property bool isPortrait: screen.height > screen.width
        property var portraitSize: Qt.size(screen.width / 1.5, screen.height / 3)
        property var landscapeSize: Qt.size(screen.width / 2, screen.height / 1.5)

        minimumSize: isPortrait ? portraitSize : landscapeSize
        maximumSize: isPortrait ? portraitSize : landscapeSize

        color: Qt.rgba(0.33, 0.33, 0.41, 0.78)

        Behavior on height {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.InOutQuad
            }
        }

        GridLayout {
            id: gridLayout
            anchors.fill: parent
            columns: 2
            columnSpacing: 1

            Rectangle {
                Layout.preferredWidth: parent.width * 0.3
                Layout.fillHeight: true
                color: Qt.rgba(0, 0, 0, 0.6)
                border.color: Color.accent
                border.width: 1

                Column {
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    spacing: 10

                    Button {
                        width: parent.width
                        height: 40
                        text: qsTr("Close")
                        hoverEnabled: true
                        background: Rectangle {
                            color: Scripts.setOpacity(Color.accent, 0.8)
                            radius: 5
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        onHoveredChanged: {
                            background.color = hovered ? Color.accent : Scripts.setOpacity(Color.accent, 0.8);
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(0, 0, 0, 0.6)
                border.color: Color.accent
                border.width: 1
            }
        }

        ColumnLayout {
            anchors.fill: parent
            visible: false
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 2

                TabBar {
                    id: tabBar
                    Layout.fillWidth: true

                    // TabButton {
                    //     text: qsTr("General")
                    // }
                    TabButton {
                        text: qsTr("Navbar")
                    }
                }

                StackLayout {
                    id: contentLayout
                    currentIndex: tabBar.currentIndex
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 5

                    // GeneralSettings {
                    //     id: generalConfig
                    //     Layout.fillWidth: true
                    //     Layout.fillHeight: true
                    // }
                    // Todo: replace with actual settings components
                    NavbarSettings {
                        id: navbarConfig
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
