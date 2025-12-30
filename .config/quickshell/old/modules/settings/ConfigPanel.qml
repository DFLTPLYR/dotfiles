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
                id: tabContainer
                property int selectedIndex: 1
                Layout.preferredWidth: parent.width * 0.25
                Layout.fillHeight: true
                color: Color.backgroundAlt
                border.color: Color.accent
                border.width: 1

                Column {
                    anchors {
                        fill: parent
                        margins: 2
                    }
                    spacing: 1

                    Repeater {
                        model: ["General", "Navbar"]
                        delegate: Button {
                            property bool selected: tabContainer.selectedIndex === index
                            width: parent.width
                            height: 40
                            text: qsTr(modelData)
                            hoverEnabled: true
                            background: Rectangle {
                                color: Scripts.setOpacity(Color.accent, 0.8)
                                radius: 0
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                            onSelectedChanged: {
                                if (selected) {
                                    background.color = Color.accent;
                                } else {
                                    background.color = Scripts.setOpacity(Color.accent, 0.8);
                                }
                            }
                            onHoveredChanged: {
                                background.color = hovered || selected ? Color.accent : Scripts.setOpacity(Color.accent, 0.8);
                            }
                            onClicked: {
                                tabContainer.selectedIndex = index;
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Color.backgroundAlt
                border.color: Color.accent
                border.width: 1

                StackLayout {
                    anchors.fill: parent
                    currentIndex: tabContainer.selectedIndex
                    Item {
                        id: homeTab
                        GeneralSettings {
                            id: generalSettingsConfig
                            anchors {
                                fill: parent
                                margins: 5
                            }
                        }
                    }
                    Item {
                        id: discoverTab
                        NavbarSettings {
                            id: navbarConfig
                            anchors {
                                fill: parent
                                margins: 5
                            }
                        }
                    }
                    Item {
                        id: activityTab
                        Rectangle {
                            anchors.fill: parent
                            color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
                        }
                    }
                }
            }
        }
    }
}
