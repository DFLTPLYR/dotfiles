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
          return "navbar-top";
        case "wallpaper":
          return "hexagon-image";
        default:
          return "?";
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

                                FontIcon {
                                    anchors.centerIn: parent
                                    text:  getIcon(modelData)
                                    font.pixelSize: parent.height
                                    color: "white"
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                            MouseArea {
                                id: ma
                                hoverEnabled: true
                                anchors.fill: parent
                            }
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
