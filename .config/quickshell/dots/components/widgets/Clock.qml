import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.config

Wrapper {
    id: wrap
    property string icon: "clock-nine"
    property int widgetHeight: 100
    property int widgetWidth: 100

    margin {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }
    GridLayout {
        columns: Navbar.config.side ? 1 : 2
        rows: Navbar.config.side ? 2 : 1
        anchors.fill: parent

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }
        Text {
            text: Qt.formatDateTime(clock.date, Navbar.config.side ? "HH : MM AP" : "hh:mm AP")
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Colors.color.primary
            fontSizeMode: Text.Fit
            font.pixelSize: Math.min(wrap.contentWidth, wrap.contentHeight)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
