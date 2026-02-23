import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    id: cpu
    property string icon: "circuit"
    property int widgetHeight: 100
    property int widgetWidth: 100

    GridLayout {
        columns: Navbar.config.side ? 1 : 2
        rows: Navbar.config.side ? 2 : 1
        anchors.fill: parent

        FontIcon {
            text: "circuit"
            color: Colors.color.primary
            font.pixelSize: Navbar.config.side
                ? Math.min(cpu.contentWidth, cpu.contentHeight / 2) * 0.6
                : Math.min(cpu.contentWidth / 2, cpu.contentHeight) * 0.6
        }

        Text {
            text: `${Hardware.cpuUsagePercent.toFixed(2)} %`
            color: Colors.color.primary
            font.pixelSize: Navbar.config.side
                ? Math.min(cpu.contentWidth, cpu.contentHeight / 2) * 0.4
                : Math.min(cpu.contentWidth / 2, cpu.contentHeight) * 0.4
        }
    }
}
