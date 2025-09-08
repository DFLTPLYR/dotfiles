import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.lottieqt

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

import qs
import qs.utils
import qs.assets
import qs.services
import qs.components

Rectangle {
    anchors.fill: parent
    color: Scripts.setOpacity(Assets.background, 0.8)

    Item {
        id: wrapper
        anchors.fill: parent

        anchors {
            rightMargin: 5
            leftMargin: 5
        }

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
                // spacing: 10

                Workspaces {}
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
                spacing: 2

                // Workspaces {}
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
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "\uf011"
                    size: parent.height
                    iconRatio: 0.5
                    backgroundColor: Assets.background
                    hoverColor: Assets.color15
                    iconColor: Assets.color10
                    onClicked: {
                        GlobalState.isSessionMenuOpen = true;
                    }
                }
            }
        }
    }
}
