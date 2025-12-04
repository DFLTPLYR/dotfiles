pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.modules.sessionmenu
import qs.components
import qs.services
import qs.assets
import qs.config

Scope {
    id: root
    LazyLoader {
        active: Config.sessionMenuOpen
        component: Variants {
            property color backgroundColor: "#e60c0c0c"
            property color buttonColor: "#1e1e1e"
            property color buttonHoverColor: "#3700b3"

            default property list<LogoutButton> buttons: [
                LogoutButton {
                    command: "systemctl suspend"
                    keybind: Qt.Key_U
                    text: "Suspend"
                    icon: CustomIcon {
                        anchors.centerIn: parent
                        name: "\uf28b"
                        size: 64
                        color: Color.color9
                    }
                },
                LogoutButton {
                    command: "systemctl hibernate"
                    keybind: Qt.Key_H
                    text: "Hibernate"
                    icon: CustomIcon {
                        anchors.centerIn: parent
                        name: "\uf236"
                        size: 64
                        color: Color.color9
                    }
                },
                LogoutButton {
                    command: "systemctl poweroff"
                    keybind: Qt.Key_K
                    text: "Shutdown"
                    icon: CustomIcon {
                        anchors.centerIn: parent
                        name: "\uf011"
                        size: 64
                        color: Color.color9
                    }
                },
                LogoutButton {
                    command: "systemctl reboot"
                    keybind: Qt.Key_R
                    text: "Reboot"
                    icon: CustomIcon {
                        anchors.centerIn: parent
                        name: "\uf2f1"
                        size: 64
                        color: Color.color9
                    }
                }
            ]

            model: Quickshell.screens

            PanelWindow {
                id: window

                property var modelData
                screen: modelData

                color: "transparent"

                contentItem {
                    focus: true
                    Keys.onPressed: event => {
                        if (event.key == Qt.Key_Escape)
                            Config.sessionMenuOpen = false;
                        else {
                            for (let i = 0; i < buttons.length; i++) {
                                let button = buttons[i];
                                if (event.key == button.keybind)
                                    button.exec();
                            }
                        }
                    }
                }

                anchors {
                    top: true
                    left: true
                    bottom: true
                    right: true
                }

                Rectangle {
                    color: backgroundColor
                    anchors.fill: parent

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Config.sessionMenuOpen = false

                        Rectangle {
                            anchors.centerIn: parent

                            radius: 50

                            width: Math.round(parent.width * 0.75)
                            height: Math.round(parent.height * 0.75)

                            GridLayout {
                                anchors.fill: parent
                                columns: 2
                                columnSpacing: 0
                                rowSpacing: 0

                                Repeater {
                                    model: buttons
                                    delegate: Rectangle {
                                        required property LogoutButton modelData

                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        color: ma.containsMouse ? buttonHoverColor : buttonColor

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 800
                                                easing.type: Easing.InOutQuad
                                            }
                                        }

                                        MouseArea {
                                            id: ma
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: modelData.exec()
                                        }

                                        CustomIcon {
                                            id: icon
                                            anchors.centerIn: parent
                                            name: modelData.icon.name
                                            size: parent.width * 0.25
                                            color: ma.containsMouse ? modelData.icon.color : Color.color12
                                        }

                                        Text {
                                            anchors {
                                                top: icon.bottom
                                                topMargin: 20
                                                horizontalCenter: parent.horizontalCenter
                                            }

                                            text: modelData.text
                                            font.pointSize: 20
                                            color: ma.containsMouse ? modelData.icon.color : Color.color15
                                        }
                                    }
                                }
                            }
                        }
                    }
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
    }
}
