import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core

Wrapper {
    id: wrap
    // properties
    objectName: "Clock"
    setHeight: 100
    setWidth: 100
    relativeX: 0
    relativeY: 0
    position: -1
    // properties

    GridLayout {
        anchors.fill: parent

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }
        Text {
            text: Qt.formatDateTime(clock.date, wrap.side ? "hh mm AP" : "hh:mm AP")
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
