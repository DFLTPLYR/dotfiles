import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core

Wrapper {
    id: wrap
    objectName: "Clock"
    setHeight: 500
    setWidth: 100
    relativeX: 0
    relativeY: 0
    position: -1

    GridLayout {
        anchors.fill: parent

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }
        Text {
            text: Qt.formatDateTime(clock.date, "hh:mm AP")
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
