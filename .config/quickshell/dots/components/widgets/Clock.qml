import QtQuick

import Quickshell
import qs.config

Wrapper {
    property string icon: "clock-nine"
    property int widgetHeight: 100
    property int widgetWidth: 100

    margin {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }

    Text {
        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        text: Qt.formatDateTime(clock.date, Navbar.config.side ? "HH : MM AP" : "hh:mm AP")
        color: Colors.color.primary
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        wrapMode: Navbar.config.side ? Text.Wrap : Text.NoWrap
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
