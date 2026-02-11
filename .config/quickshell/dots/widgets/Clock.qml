import QtQuick

import Quickshell
import qs.config

Item {
    property string handler
    property bool isSlotted: false

    property real widgetWidth
    property real widgetHeight

    width: {
        if (widgetWidth !== 0 && !Navbar.config.side) {
            return widgetWidth;
        }
        return parent ? parent.width : 0;
    }

    height: {
        if (widgetHeight !== 0 && Navbar.config.side) {
            return widgetHeight;
        }
        return parent ? parent.height : 0;
    }

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
