import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.config
import qs.components

Scope {
    Connections {
        target: Config
        function onOpenSettingsPanelChanged() {
            settingsLoader.active = !settingsLoader.active;
        }
    }

    function getIcon(name) {
        switch (name) {
        case "general":
            return "gear-icon";
        case "navbar":
            return `navbar-${Config.navbar.position}`;
        case "wallpaper":
            return "hexagon-image";
        default:
            return "?";
        }
    }

    LazyLoader {
        id: settingsLoader
        component: FloatingWindow {
            id: root
            title: "SettingsPanel"
            property int page: 0
            readonly property bool isPortrait: screen.height > screen.width
            readonly property size panelSize: isPortrait ? Qt.size(screen.width * 0.6, screen.height * 0.4) : Qt.size(screen.width * 0.4, screen.height * 0.6)
            minimumSize: panelSize
            maximumSize: panelSize
            color: Qt.rgba(0, 0, 0, 0.8)

            GridLayout {
                columns: 2
                anchors.fill: parent

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40

                    ListView {
                        anchors.fill: parent
                        spacing: 1
                        model: ["general", "navbar", "wallpaper"]
                        delegate: Item {
                            width: 40
                            height: 40
                            Rectangle {
                                anchors.fill: parent
                                color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                                radius: ma.containsMouse ? 8 : 0

                                FontIcon {
                                    anchors.centerIn: parent
                                    text: getIcon(modelData)
                                    font.pixelSize: parent.height
                                    color: ma.containsMouse || root.page === index ? "white" : Qt.rgba(1, 1, 1, 0.6)

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 350
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }

                                Behavior on radius {
                                    NumberAnimation {
                                        duration: 350
                                        easing.type: Easing.InOutQuad
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 350
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            MouseArea {
                                id: ma
                                hoverEnabled: true
                                anchors.fill: parent
                                onClicked: {
                                    page = index;
                                }
                            }
                        }
                    }
                }
                StackLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: 600
                    currentIndex: root.page
                    Layout.rightMargin: 10

                    PageWrapper {
                        PageHeader {
                            title: "General"
                        }
                        PageFooter {}
                    }
                    PageWrapper {
                        PageHeader {
                            title: "Navbar"
                        }
                        // property string position: "top" // top, bottom, left, right
                        // property bool side: position === "left" || position === "right"
                        // property PopupProps popup: PopupProps {}
                        // property int width: 50
                        // property int height: 50
                        PageFooter {}
                    }
                    PageWrapper {
                        PageHeader {
                            title: "Wallpaper"
                        }
                        PageFooter {}
                    }
                }
            }
        }
    }
    component PageWrapper: ScrollView {
        default property alias contentLayout: contentLayout.data
        Layout.fillHeight: true
        Layout.fillWidth: true
        contentWidth: width
        clip: true
        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
        }
    }

    component PageHeader: Item {
        property alias title: titleText.text
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Text {
            id: titleText
            anchors.centerIn: parent
            color: "white"
        }
    }

    component PageFooter: Item {
        property alias footerLayout: footerLayout.data
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        RowLayout {
            id: footerLayout
            width: parent.width

            Text {
                Layout.fillWidth: true
                text: "Save Settings"
                color: "white"
            }

            Row {
                spacing: 10
                Button {
                    id: cancelButton
                    text: "Cancel"
                    width: 80

                    background: StyledRect {
                        borderRadius: 2
                        anchors.fill: parent
                        color: cancelButton.hovered ? "#BDBDBD" : "#757575"
                    }

                    onClicked: {
                        Config.openSettingsPanel = false;
                    }
                }
                Button {
                    id: saveButton
                    text: "Save"
                    width: 80

                    background: StyledRect {
                        borderRadius: 2
                        anchors.fill: parent
                        color: saveButton.hovered ? "#4CAF50" : "#388E3C"
                    }

                    onClicked: {
                        Config.saveSettings();
                        Qt.callLater(() => {
                            Config.openSettingsPanel = false;
                        });
                    }
                }
            }
        }
    }
}
