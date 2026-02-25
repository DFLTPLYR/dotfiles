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
            Layout.preferredHeight: Navbar.config.side ? parent.width : parent.height
            Layout.preferredWidth: height
            color: Colors.color.primary
            font.pixelSize: Math.min(width, height)
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: `${Hardware.gpuUsagePercent} %`
            Layout.preferredHeight: Navbar.config.side ? parent.width : parent.height
            Layout.preferredWidth: height
            color: Colors.color.primary
            font.pixelSize: Navbar.config.side ? Math.min(gpu.contentWidth, gpu.contentHeight) / 2 : Math.min(gpu.contentWidth, gpu.contentHeight)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
