import QtQuick
import Quickshell
import qs.components

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property ShellScreen modelData
        screen: modelData
        anchors {
            top: true
            left: true
            right: true
        }
        color: "transparent"
        implicitHeight: 50

        // parent
        StyledRect {
            width: parent.width
            height: parent.height
            fill: true
            color: Qt.rgba(0, 0, 0, 0.5)
            Text {
                id: test
                text: "time"
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
