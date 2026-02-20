import QtQuick

import qs.utils
import qs.config

Item {
    default property alias content: handler.data
    property string handler
    property bool isSlotted: false
    property bool enableActions: true
    property int position
    property real widgetWidth
    property real widgetHeight

    Rectangle {
        id: handler
        color: Scripts.setOpacity(Colors.color.on_primary, 0.8)
        border.color: Colors.color.primary
        radius: width / 2
        clip: true

        anchors {
            fill: parent
            topMargin: 10
            bottomMargin: 10
            leftMargin: 0
            rightMargin: 0
        }
    }

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
