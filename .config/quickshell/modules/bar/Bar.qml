import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick.Shapes
import Quickshell.Wayland

// component
import qs.utils
import qs.assets
import qs.services
import qs.components

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: screenRoot
        required property var modelData
        screen: modelData
        color: "transparent"
        implicitHeight: barComponent.height

        anchors {
            top: true
            left: true
            right: true
        }

        Rectangle {
            id: barComponent
            width: parent.width
            height: 40
            color: Scripts.setOpacity(ColorPalette.background, 0.8)

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.preferredWidth: parent.width * 0.25
                    height: 32
                    color: "transparent"

                    Workspaces {}
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: "transparent"
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: qsTr("text")
                        color: "white"
                    }
                }

                Rectangle {
                    Layout.preferredWidth: parent.width * 0.25
                    height: 32
                    color: "transparent"

                    NavButtons {}
                }
            }
        }
    }
}
