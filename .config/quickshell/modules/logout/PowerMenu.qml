import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.modules.Logout
import qs.components
import qs.services

Variants {
    id: root
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
                color: Colors.color9
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
                color: Colors.color9
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
                color: Colors.color9
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
                color: Colors.color9
            }
        }
    ]

    model: Quickshell.screens
    PanelWindow {
        id: window

        property var modelData
        screen: modelData

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        color: "transparent"

        contentItem {
            focus: true
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape)
                    Qt.quit();
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
                onClicked: Qt.quit()

                GridLayout {
                    anchors.centerIn: parent

                    width: Math.round(parent.width * 0.75)
                    height: Math.round(parent.height * 0.75)

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
                            border.color: "black"
                            border.width: ma.containsMouse ? 0 : 1

                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: modelData.exec()
                            }

                            // Replace Image with CustomIcon
                            CustomIcon {
                                id: icon
                                anchors.centerIn: parent
                                name: modelData.icon.name
                                size: parent.width * 0.25
                                color: ma.containsMouse ? modelData.icon.color : Colors.color12
                            }

                            Text {
                                anchors {
                                    top: icon.bottom
                                    topMargin: 20
                                    horizontalCenter: parent.horizontalCenter
                                }

                                text: modelData.text
                                font.pointSize: 20
                                color: ma.containsMouse ? modelData.icon.color : Colors.color15
                            }
                        }
                    }
                }
            }
        }
    }
}
