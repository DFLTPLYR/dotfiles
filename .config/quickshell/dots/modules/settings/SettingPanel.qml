import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.config

Scope {
    Connections {
        target: Config
        function onOpenSettingsPanelChanged() {
            settingsLoader.active = !settingsLoader.active;
        }
    }

    LazyLoader {
        id: settingsLoader
        component: FloatingWindow {
            title: "SettingsPanel"
            readonly property bool isPortrait: screen.height > screen.width
            readonly property size panelSize: isPortrait ? Qt.size(screen.width * 0.6, screen.height * 0.4) : Qt.size(screen.width * 0.4, screen.height * 0.6)
            minimumSize: panelSize
            maximumSize: panelSize
            color: Qt.rgba(0, 0, 0, 0.6)

            GridLayout {
                columns: 2
                anchors.fill: parent

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width / 10

                    ListView {
                        anchors.fill: parent
                        spacing: 1
                        model: ["general", "navbar", "wallpaper", "extended-navbar"]
                        delegate: Item {
                            width: parent ? parent.width : null
                            height: 40
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ScrollView {
                        width: parent.width
                        height: parent.height
                        anchors.left: parent.left
                        anchors.right: parent.right
                        contentWidth: width
                        clip: true

                        ColumnLayout {
                            width: parent.width

                            // Controls
                            Item {
                                id: controls

                                Layout.fillWidth: true
                                Layout.preferredHeight: controlFlow.implicitHeight
                                Text {
                                    text: "General Settings"
                                    color: "white"
                                }

                                Flow {
                                    id: controlFlow
                                    anchors.fill: parent
                                    spacing: 20
                                    width: parent.width
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
