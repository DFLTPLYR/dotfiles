import QtQuick

import qs.config
import qs.components

Wrapper {
    Row {
        anchors.centerIn: parent
        spacing: 8

        FontIcon {
            text: "gaming-pad-alt"
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.height, parent.width)
        }
        Text {
            text: `${Hardware.gpuUsagePercent} %`
            color: Colors.color.primary
        }
    }
}
