import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    id: gpu
    property string icon: "gaming-pad-alt"
    property int widgetHeight: 100
    property int widgetWidth: 100

    margin {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }

    GridLayout {
        anchors.fill: parent
        columns: Navbar.config.side ? 1 : 2
        rows: Navbar.config.side ? 2 : 1

        FontIcon {
            text: "gaming-pad-alt"
            color: Colors.color.primary
            font.pixelSize: Navbar.config.side ? Math.min(gpu.contentWidth, gpu.contentHeight / 2) * 0.6 : Math.min(gpu.contentWidth / 2, gpu.contentHeight) * 0.6
        }

        Text {
            text: `${Hardware.gpuUsagePercent} %`
            color: Colors.color.primary
            font.pixelSize: Navbar.config.side ? Math.min(gpu.contentWidth, gpu.contentHeight / 2) * 0.4 : Math.min(gpu.contentWidth / 2, gpu.contentHeight) * 0.4
        }
    }
}
