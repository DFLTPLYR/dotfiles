import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.components
import qs.types

Wrapper {

    config: Property {
        property int width: 80
        property int height: 80
    }

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
            font {
                pixelSize: Math.min(parent.width, parent.height) / 3
            }
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
