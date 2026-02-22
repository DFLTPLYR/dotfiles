import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    property string icon: "circuit"
    property int widgetHeight: 100
    property int widgetWidth: 100
    property Spacing padding: Spacing {}

    GridLayout {
        columns: Navbar.config.side ? 1 : 2
        rows: Navbar.config.side ? 2 : 1

        anchors {
            fill: parent

            // padding
            leftMargin: Navbar.config.side ? 0 : padding.left
            rightMargin: Navbar.config.side ? 0 : padding.right
            topMargin: Navbar.config.side ? padding.top : 0
            bottomMargin: Navbar.config.side ? padding.bottom : 0
        }
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
