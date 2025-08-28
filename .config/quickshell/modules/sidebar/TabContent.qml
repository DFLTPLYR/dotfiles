import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.services
import qs.utils
import qs.modules.sidebar.Calculator
import qs.modules.sidebar.todo

StackLayout {
    id: container
    currentIndex: 1

    ContentWrapper {
        index: 0
        Layout.fillHeight: true
        Layout.fillWidth: true

        // Calculator {}
    }
    ContentWrapper {
        index: 1
        Layout.fillHeight: true
        Layout.fillWidth: true

        Todo {}
    }
    ContentWrapper {
        index: 2
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    opacity: animProgress
}
