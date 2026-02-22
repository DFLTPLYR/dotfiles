import QtQuick

import qs.utils
import qs.config

Item {
    id: wrap

    default property alias content: handler.data

    property string handler
    property bool isSlotted: false
    property bool enableActions: true
    property int position
    property real wrapWidth
    property real wrapHeight

    // padding
    property int leftPadding: 10
    property int rightPadding: 10
    property int topPadding: 10
    property int bottomPadding: 10

    Rectangle {
        id: handler
        color: Scripts.setOpacity(Colors.color.on_primary, 0.8)
        border.color: Colors.color.primary
        radius: width / 2
        clip: true

        anchors {
            fill: parent
            // padding
            bottomMargin: Navbar.config.side ? 0 : wrap.bottomPadding
            topMargin: Navbar.config.side ? 0 : wrap.topPadding
            leftMargin: Navbar.config.side ? wrap.leftPadding : 0
            rightMargin: Navbar.config.side ? wrap.rightPadding : 0
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
