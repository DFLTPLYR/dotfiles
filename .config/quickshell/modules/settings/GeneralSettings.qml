import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.components
import qs.assets

import qs.config
import qs.utils

Item {
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
