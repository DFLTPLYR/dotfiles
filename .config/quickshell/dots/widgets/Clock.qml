import QtQuick

import Quickshell
import qs.config

Wrapper {
    Item {
        id: widgetHandler
        anchors.fill: parent
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
}
