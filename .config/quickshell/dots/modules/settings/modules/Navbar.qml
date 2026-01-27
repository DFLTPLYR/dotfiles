import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.utils
import qs.config
import qs.components

PageWrapper {
    id: root
    property ShellScreen selectedScreen: null
    property int navbarWidth
    property int navbarHeight

    PageHeader {
        title: "Navbar"
    }
    Spacer {}

    RowLayout {
        id: screenSelector

        StyledButton {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 40
            hoverEnabled: true
            colorBackground: root.selectedScreen === null ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.primary, 1) : Scripts.setOpacity(Colors.color.background, 1)

            borderRadius: 0
            borderWidth: 1
            borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

            RowLayout {
                anchors {
                    fill: parent
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                FontIcon {
                    text: "monitor"
                    font.pixelSize: parent.height / 2
                    color: Colors.color.secondary
                }
                Text {
                    text: "All"
                    font.pixelSize: parent.height / 2
                    color: Colors.color.secondary
                }
            }

            onClicked: {
                root.selectedScreen = null;
            }
        }

        Repeater {
            model: Quickshell.screens
            delegate: StyledButton {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 40
                hoverEnabled: true
                colorBackground: root.selectedScreen === modelData ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.background, 1)

                borderRadius: 0
                borderWidth: 1
                borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

                RowLayout {
                    anchors {
                        fill: parent
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                    FontIcon {
                        text: "monitor"
                        font.pixelSize: parent.height / 2
                        color: Colors.color.secondary
                    }
                    Text {
                        text: modelData.name
                        font.pixelSize: parent.height / 2
                        color: Colors.color.secondary
                    }
                }

                onClicked: {
                    root.selectedScreen = modelData;
                }
            }
        }
    }

    Label {
        text: qsTr("Panels:")
        font.pixelSize: 32
        color: Colors.color.on_surface
    }

    // Landscape
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 100
        color: "transparent"
        border.color: Colors.color.primary

        // Navbar Preview
        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            width: root.selectedScreen === null ? root.navbarWidth / 2 : root.selectedScreen.width / 2
            height: Config.navbar.height
            color: "white"
        }
    }

    GridView {
        id: colorGrid
        visible: false
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        cellHeight: width / 15
        cellWidth: width / 15
        model: Colors.colors
        delegate: Rectangle {
            width: colorGrid.cellWidth
            height: colorGrid.cellHeight
            color: Colors.color[modelData]
        }
    }

    PageFooter {
        onSave: {
            Config.saveSettings();
        }
        onSaveAndExit: {
            Config.general.previewWallpaper = [];
            Config.saveSettings();
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
        onExit: {
            Config.general.previewWallpaper = [];
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
    }
    Component.onCompleted: {
        const objects = Quickshell.screens;
        objects.forEach(obj => {
            if (obj.width > root.navbarWidth)
                root.navbarWidth = obj.width;
            if (obj.height > root.navbarHeight)
                root.navbarHeight = obj.height;
        });
    }
}
