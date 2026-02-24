import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    id: cpu
    property string icon: "circuit"
    property int widgetHeight: 100
    property int widgetWidth: 100

    margin {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }

    GridLayout {
        columns: Navbar.config.side ? 1 : 2
        rows: Navbar.config.side ? 2 : 1
        anchors.fill: parent

        FontIcon {
            text: "circuit"
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.width, parent.height)
        }

        Text {
            text: `${Hardware.cpuUsagePercent.toFixed(2)} %`
            color: Colors.color.primary
        }
    }
}
