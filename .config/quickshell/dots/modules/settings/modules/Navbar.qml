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
    property var areas: []
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
            bgColor: root.selectedScreen === null ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.primary, 1) : Scripts.setOpacity(Colors.color.background, 1)

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
                bgColor: root.selectedScreen === modelData ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.background, 1)

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

    Row {
        Label {
            text: qsTr("Panels:")
            font.pixelSize: 32
            color: Colors.color.on_surface
        }
        Repeater {
            id: orientationRepeater
            model: ["top", "bottom", "right", "left"]
            delegate: StyledButton {
                id: orientationBtn
                required property string modelData
                readonly property bool isSelected: Config.navbar.position === modelData
                enabled: !isSelected
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                bgColor: isSelected ? Colors.color.primary : Colors.color.secondary

                height: parent.height * 0.8
                width: height
                FontIcon {
                    text: `bar-${modelData}`
                    color: isSelected ? Colors.color.on_primary : Colors.color.on_secondary
                    font.pixelSize: parent.height * 0.8
                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                onClicked: {
                    Config.navbar.position = modelData;
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: root.navbarHeight * 0.5
        columns: Config.navbar.side ? 2 : 1

        // preview Panel
        Rectangle {
            Layout.fillWidth: Config.navbar.side ? false : true
            Layout.fillHeight: !Config.navbar.side ? false : true
            Layout.preferredHeight: Config.navbar.height
            Layout.preferredWidth: Config.navbar.width
            color: "transparent"
            border.color: Colors.color.primary
            Rectangle {
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                width: Config.navbar.side ? parent.width : root.selectedScreen === null ? root.navbarWidth / 2 : root.selectedScreen.width / 2
                height: Config.navbar.side ? root.selectedScreen === null ? root.navbarHeight / 2 : root.selectedScreen.height / 2 : parent.height
                color: Scripts.setOpacity(Colors.color.background, 0.9)
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    // Landscape
    // Rectangle {
    //     Layout.fillWidth: true
    //     Layout.preferredHeight: 100
    //     color: Colors.color.on_surface
    //
    //     // Navbar Preview
    //     Rectangle {
    //         anchors {
    //             verticalCenter: parent.verticalCenter
    //             horizontalCenter: parent.horizontalCenter
    //         }
    //         width: root.selectedScreen === null ? root.navbarWidth / 2 : root.selectedScreen.width / 2
    //         height: Config.navbar.height
    //         color: Scripts.setOpacity(Colors.color.background, 0.9)
    //         Repeater {
    //           id: areaRepeater
    //           model: root.areas
    //           delegate: RowLayout {
    //
    //           }
    //         }
    //     }
    // }

    Row {
        Label {
            text: qsTr("Areas:")
            font.pixelSize: 32
            color: Colors.color.on_surface
        }
        StyledButton {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            height: parent.height * 0.8
            width: height
            FontIcon {
                text: "plus"
                font.pixelSize: parent.height * 0.8
                color: Colors.color.secondary
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }
            onClicked: {
                const container = {
                    name: "",
                    direction: Qt.AlignVCenter | Qt.AlignRight
                };
                root.areas = [container, ...root.areas];
            }
            // Qt::AlignLeft
            // Qt::AlignHCenter
            // Qt::AlignRight
            // Qt::AlignTop
            // Qt::AlignVCenter
            // Qt::AlignBottom
            // Qt::AlignBaseline
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
