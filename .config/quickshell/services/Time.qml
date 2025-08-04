// Time.qml
pragma Singleton

import QtQuick
import Quickshell

QtObject {
    id: root

    property bool detailed: false

    property SystemClock clock: SystemClock {
        precision: SystemClock.Seconds
    }

    readonly property string time: Qt.formatDateTime(clock.date, detailed ? "dddd MMMM d yyyy hh:mm AP" : "ddd h:mmAP")
}
