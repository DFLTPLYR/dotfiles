import QtQuick

import Quickshell
import qs.config

Item {
    property string handler
    property bool isSlotted: false
    width: parent ? height : 0
    height: parent ? parent.height : 0

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
    }
}
