import QtQuick

import Quickshell
import qs.config

Item {
    property string handler
    property bool isSlotted: false
    property bool enableActions: true

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
}
