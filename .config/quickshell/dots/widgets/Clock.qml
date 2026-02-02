import QtQuick

import Quickshell
import qs.config

Text {
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    text: Qt.formatDateTime(clock.date, "hh:mm AP")
    color: Colors.color.primary
    anchors {
        verticalCenter: parent.verticalCenter
        horizontalCenter: parent.horizontalCenter
    }
    wrapMode: Text.Wrap
    horizontalAlignment: Text.AlignHCenter
    width: Math.min(parent.width, font.pixelSize * 6)
}
