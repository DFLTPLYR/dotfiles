import QtQuick

import Quickshell
import qs.config

Wrapper {
    Text {
        text: `${Hardware.gpuUsagePercent} %`
        color: Colors.color.primary
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        wrapMode: Text.Wrap
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }
}
