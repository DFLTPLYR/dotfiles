import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import qs.modules.settings
import qs.components

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

        minimumSize: Qt.size(screen.width / 2, screen.height / 1.5)
        maximumSize: Qt.size(screen.width / 2, screen.height / 1.5)

        property bool isPortrait: screen.height > screen.width

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

        ColumnLayout {
            anchors.fill: parent

            Item {
                id: previewArea
                visible: previewLoader.sourceComponent !== null
                Layout.fillWidth: true
                Layout.preferredHeight: screen.height * 0.2
                Layout.margins: 10

                Loader {
                    id: previewLoader
                    anchors.fill: parent
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

                    NavbarConfig {
                        id: navbarConfig
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Text {
                        text: "2"
                        font.pixelSize: 18
                    }

                    onCurrentIndexChanged: {
                        if (contentLayout.children && contentLayout.children.length > currentIndex) {
                            previewLoader.sourceComponent = contentLayout.children[currentIndex].previewComponent;
                        } else {
                            previewLoader.sourceComponent = null;
                        }
                    }

                    Component.onCompleted: {
                        if (contentLayout.children && contentLayout.children.length > currentIndex) {
                            previewLoader.sourceComponent = contentLayout.children[currentIndex].previewComponent;
                        } else {
                            console.log("No child at currentIndex or children not ready.");
                        }
                    }
                }
            }
        }
    }
}
