import QtQuick

import Quickshell
import qs.config

Wrapper {
    id: clock
    property string icon: "clock-nine"
    property int widgetHeight: 100
    property int widgetWidth: 100

    Text {
        SystemClock {
            id: sysClock
            precision: SystemClock.Seconds
        }

        text: Qt.formatDateTime(sysClock.date, "hh:mm AP")
        color: Colors.color.primary
        font.pixelSize: Math.min(clock.contentWidth, clock.contentHeight) * 0.4
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        wrapMode: Text.Wrap
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }
}
