import QtQuick

import Quickshell
import qs.config

Wrapper {
    property string icon: "clock-nine"
    property int widgetHeight: 100
    property int widgetWidth: 100
    property Spacing padding: Spacing {}
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
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }
}
