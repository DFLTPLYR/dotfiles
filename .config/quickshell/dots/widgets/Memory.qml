import QtQuick

import qs.config
import qs.components

Wrapper {
    Row {
        anchors.centerIn: parent
        spacing: 8
        FontIcon {
            text: "circuit"
            color: Colors.color.primary
            font.pixelSize: parent.height
        }
        Text {
            text: `${Hardware.memoryUsagePercent.toFixed(2)} %`
            color: Colors.color.primary
        }
    }
}
