import QtQuick

import qs.utils
import qs.config

Item {
    id: wrap

    //for child being passed cuz shieeeee
    default property alias content: handler.data

    // generics for handling reparent
    property string handler
    property bool isSlotted: false
    property bool enableActions: true
    property int position

    // size
    property real wrapWidth
    property real wrapHeight

    // margin
    property Spacing margin: Spacing {}
    property int rouding: 0

    Rectangle {
        id: handler
        color: Scripts.setOpacity(Colors.color.on_primary, 0.8)
        border.color: Colors.color.primary
        radius: wrap.rouding
        clip: true

        anchors {
            fill: parent

            // padding
            bottomMargin: wrap.margin.bottom
            topMargin: wrap.margin.top
            leftMargin: wrap.margin.bottom
            rightMargin: wrap.margin.top
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
