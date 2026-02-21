import QtQuick

import qs.config
import qs.components

Wrapper {
    property string icon: "circuit"
    property int widgetHeight: 100
    property int widgetWidth: 100
    Row {
        anchors.centerIn: parent
        spacing: 8
        FontIcon {
            text: "circuit"
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.height, parent.width)
        }
        Text {
            text: `${Hardware.cpuUsagePercent.toFixed(2)} %`
            color: Colors.color.primary
        }
    }
}
