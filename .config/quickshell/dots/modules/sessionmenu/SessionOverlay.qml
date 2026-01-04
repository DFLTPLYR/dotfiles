import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.config
import qs.components

LazyLoader {
    active: Config.openSessionMenu
    component: Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            required property ShellScreen modelData
            screen: modelData

            color: "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            anchors {
                top: true
                bottom: true
                right: true
                left: true
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

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.5)

                MouseArea {
                    anchors.fill: parent
                    onClicked: Config.openSessionMenu = false
                    hoverEnabled: true
                    onHoverEnabledChanged: {
                        parent.focus = hoverEnabled;
                    }
                }

                StyledRect {
                    width: parent.width * 0.5
                    height: parent.height * 0.5
                    x: parent.width * 0.25
                    y: parent.height * 0.25
                    color: Qt.rgba(0, 0, 0, 0.5)
                    borderRadius: 100
                    clip: false
                    borderWidth: 2
                    borderColor: "white"
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

            Component.onCompleted: {
                if (this.WlrLayershell) {
                    this.exclusionMode = ExclusionMode.Ignore;
                    this.WlrLayershell.layer = WlrLayer.Top;
                    this.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive;
                }
            }
        }
    }
}
