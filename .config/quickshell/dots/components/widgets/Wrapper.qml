import QtQuick

import qs.utils
import qs.config

Item {
    default property alias content: handler.data
    property string handler
    property bool isSlotted: false
    property bool enableActions: true
    property int position
    property real wrapWidth
    property real wrapHeight

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
            leftMargin: 10
            rightMargin: 10
        }
    }

    width: {
        if (wrapWidth !== 0 && !Navbar.config.side) {
            return wrapWidth;
        }
        return parent ? parent.width : 0;
    }

    height: {
        if (wrapHeight !== 0 && Navbar.config.side) {
            return wrapHeight;
        }
        return parent ? parent.height : 0;
    }
}
