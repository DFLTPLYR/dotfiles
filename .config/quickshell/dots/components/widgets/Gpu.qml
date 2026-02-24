import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    id: gpu
    property string icon: "gaming-pad-alt"
    property int widgetHeight: 100
    property int widgetWidth: 100

    GridLayout {
        anchors.fill: parent
        columns: Navbar.config.side ? 1 : 2
        rows: Navbar.config.side ? 2 : 1

        FontIcon {
            text: "gaming-pad-alt"
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.width, parent.height)
        }

        Text {
            text: `${Hardware.gpuUsagePercent} %`
            color: Colors.color.primary
        }
    }
}
