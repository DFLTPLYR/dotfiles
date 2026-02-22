import QtQuick

import qs.config
import qs.components

Wrapper {
    property string icon: "gaming-pad-alt"
    property int widgetHeight: 100
    property int widgetWidth: 100
    property Spacing padding: Spacing {}
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
