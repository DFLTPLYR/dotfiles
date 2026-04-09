import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.types

GridLayout {
    property Property config: Property {
        property int height: 100
        property int width: 100
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Colors.color.primary
        font {
            pixelSize: Math.min(parent.width, parent.height) / 3
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
