import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.utils

StackLayout {
    currentIndex: 1

    ContentWrapper {
        index: 0
        Layout.fillHeight: true
        Layout.fillWidth: true
        Text {
            id: calendar
            text: qsTr("text")
        }
    }
    ContentWrapper {
        index: 1
        Layout.fillHeight: true
        Layout.fillWidth: true
        Text {
            text: qsTr("Todo Widget")
            color: Colors.color12
        }
        Text {
            text: qsTr("Todo Widget")
            color: Colors.color12
        }
        Text {
            text: qsTr("Todo Widget")
            color: Colors.color12
        }
    }

    opacity: animProgress
}
