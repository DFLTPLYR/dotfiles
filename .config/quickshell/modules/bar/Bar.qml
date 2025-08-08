import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell.Widgets
import Qt.labs.lottieqt
import QtQuick.Shapes

import qs.services
import qs.components
import qs.assets
import qs
import Quickshell.Wayland

Rectangle {
    anchors.fill: parent
    color: Colors.background
    opacity: 1
    // radius: 20

    Item {
        id: wrapper
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: parent.width * 0.002

        // LEFT section: 25% width
        Item {
            id: left
            width: parent.width * 0.25
            height: parent.height
            anchors.left: parent.left
            clip: false

            Row {
                id: leftRow
                height: left.height * 0.95
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Clock {}

                Weather {}

                // SystemInfo {}
            }
        }

        // CENTER section: 50% width
        Item {
            id: center
            width: parent.width * 0.5
            height: parent.height
            anchors.centerIn: parent
            clip: true

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.centerIn: parent
                spacing: 8

                Workspaces {}
            }
        }

        // RIGHT section: 25% width
        Item {
            id: right
            width: parent.width * 0.25
            height: parent.height
            anchors.right: parent.right
            clip: true

            Row {
                height: right.height * 0.95
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                spacing: 2

                StyledButton {
                    Layout.alignment: Qt.AlignRight
                    icon: "\uf011"
                    size: parent.height
                    iconRatio: 0.5
                    backgroundColor: Colors.background
                    hoverColor: Colors.color15
                    iconColor: Colors.color10
                    onClicked: {
                        return;
                    }
                }
            }
        }
    }
}
