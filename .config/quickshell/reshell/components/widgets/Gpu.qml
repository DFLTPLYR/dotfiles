import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.components

Wrapper {
    id: wrap
    // properties
    objectName: "Gpu"
    setHeight: 100
    setWidth: 100
    relativeX: 0
    relativeY: 0
    position: -1
    // properties
    GridLayout {
        anchors.fill: parent
        columns: wrap.side ? 1 : 2
        rows: wrap.side ? 2 : 1

        Icon {
            text: "gaming-pad-alt"
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            font.pixelSize: Math.min(width, height)
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            text: `${Hardware.gpuUsagePercent.toFixed(0)} %`
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            font {
                pixelSize: Math.min(wrap.width, wrap.height) / 2
            }
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
