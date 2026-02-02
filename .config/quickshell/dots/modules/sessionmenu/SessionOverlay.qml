import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

Scope {
    LazyLoader {
        id: sessionMenuLoader
        property bool shouldBeVisible: false
        component: PanelWrapper {
            id: screenPanel
            color: "transparent"
            shouldBeVisible: sessionMenuLoader.shouldBeVisible

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            contentItem {
                focus: true
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Escape) {
                        Config.openSessionMenu = false;
                    }
                }
            }

            default property list<ProcessButton> buttons: [
                ProcessButton {
                    command: "systemctl suspend"
                    keybind: Qt.Key_U
                    text: "Suspend"
                    icon: FontIcon {
                        anchors.centerIn: parent
                        text: "door-open"
                    }
                },
                ProcessButton {
                    command: "systemctl hibernate"
                    keybind: Qt.Key_H
                    text: "Hibernate"
                    icon: FontIcon {
                        anchors.centerIn: parent
                        text: "ghost"
                    }
                },
                ProcessButton {
                    command: "systemctl poweroff"
                    keybind: Qt.Key_K
                    text: "Shutdown"
                    icon: FontIcon {
                        anchors.centerIn: parent
                        text: "power-off"
                    }
                },
                ProcessButton {
                    command: "systemctl reboot"
                    keybind: Qt.Key_R
                    text: "Reboot"
                    icon: FontIcon {
                        anchors.centerIn: parent
                        text: "\uf2f1"
                    }
                }
            ]

            PopupWindow {
                anchor.window: screenPanel
                anchor.rect.x: parentWindow.width / 2 - width / 2
                anchor.rect.y: (parentWindow.screen.height / 2 - height / 2)
                implicitWidth: screenPanel.isPortrait ? parentWindow.screen.width * 0.8 : parentWindow.screen.width * 0.5
                implicitHeight: parentWindow.screen.height * 0.6
                color: "transparent"
                visible: screenPanel.internalVisible

                StyledRect {
                    anchors.fill: parent
                    opacity: screenPanel.animProgress
                    color: Colors.color.background
                    borderColor: Colors.color.secondary
                    borderRadius: 50
                    Behavior on height {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    GridLayout {
                        anchors.fill: parent
                        columns: 2
                        columnSpacing: 0
                        rowSpacing: 0
                        Repeater {
                            id: buttonRepeater
                            model: buttons
                            delegate: Rectangle {
                                required property ProcessButton modelData

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "transparent"

                                FontIcon {
                                    id: icon
                                    anchors.centerIn: parent
                                    text: modelData.icon.text
                                    color: ma.containsMouse ? "gray" : "white"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }

                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        modelData.exec();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            onHidden: {
                sessionMenuLoader.active = false;
            }

            Component.onCompleted: {
                if (this.WlrLayershell) {
                    this.WlrLayershell.layer = WlrLayer.Overlay;
                    this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                    this.exclusionMode = ExclusionMode.Ignore;
                }
            }
        }
    }
    Connections {
        target: Config
        function onOpenSessionMenuChanged() {
            if (!sessionMenuLoader.active) {
                sessionMenuLoader.active = true;
                sessionMenuLoader.shouldBeVisible = !sessionMenuLoader.shouldBeVisible;
            } else {
                sessionMenuLoader.shouldBeVisible = !sessionMenuLoader.shouldBeVisible;
            }
        }
    }
}
