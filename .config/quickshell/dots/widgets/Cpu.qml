import QtQuick

import Quickshell

import qs.config
import qs.components

Wrapper {
    Row {
        anchors.centerIn: parent
        spacing: 8

        FontIcon {
            text: "gaming-pad-alt"
            color: Colors.color.primary
            font.pixelSize: parent.height
        }
        Text {
            text: `${Hardware.cpuUsagePercent.toFixed(2)} %`
            color: Colors.color.primary
        }
    }
}
