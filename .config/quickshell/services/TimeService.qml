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

    // Raw values from SystemClock
    readonly property int rawHours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds
    readonly property date date: clock.date

    // 12-hour conversion with zero padding
    readonly property string hoursPadded: {
        let h = rawHours % 12;
        if (h === 0)
            h = 12;
        return h < 10 ? "0" + h : "" + h;
    }
    readonly property string minutesPadded: minutes < 10 ? "0" + minutes : "" + minutes
    readonly property string ampm: rawHours >= 12 ? "PM" : "AM"

    // Formatted strings
    readonly property string dateString: Qt.formatDateTime(clock.date, "yyyy-MM-dd")
    readonly property string fullTime: hoursPadded + ":" + minutesPadded + " " + ampm

    readonly property int year: parseInt(Qt.formatDateTime(clock.date, "yyyy"))
    readonly property int month: parseInt(Qt.formatDateTime(clock.date, "M"))
    readonly property int day: parseInt(Qt.formatDateTime(clock.date, "d"))
}
