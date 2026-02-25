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
            Layout.preferredHeight: Navbar.config.side ? parent.width : parent.height
            Layout.preferredWidth: height
            text: "circuit"
            color: Colors.color.primary
            font.pixelSize: Math.min(width, height)
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: `${Hardware.cpuUsagePercent.toFixed(2)} %`
            color: Colors.color.primary
            fontSizeMode: Text.Fit
            font.pixelSize: Math.min(cpu.contentWidth, cpu.contentHeight)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
