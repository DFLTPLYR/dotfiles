import QtQuick

import qs.utils
import qs.config

Item {
    id: wrap

    default property alias content: contentItem.data

    // generics for handling reparent
    property string handler
    property bool isSlotted: false
    property bool enableActions: true
    property int position

    // size
    property real wrapWidth
    property real wrapHeight

    // margin (outside the rectangle)
    property Spacing margin: Spacing {}

    // padding (inside the rectangle)
    property Spacing padding: Spacing {}

    property int rouding: 0

    // expose the usable content area so children can size fonts relative to it
    readonly property real contentWidth: contentItem.width
    readonly property real contentHeight: contentItem.height

    Rectangle {
        id: background
        color: Scripts.setOpacity(Colors.color.on_primary, 0.8)
        border.color: Colors.color.primary
        radius: wrap.rouding
        clip: true

        anchors {
            fill: parent
            topMargin: wrap.margin.top
            bottomMargin: wrap.margin.bottom
            leftMargin: wrap.margin.left
            rightMargin: wrap.margin.right
        }

        // content area with padding applied
        Item {
            id: contentItem
            anchors {
                fill: parent
                leftMargin: wrap.padding.left
                rightMargin: wrap.padding.right
                topMargin: wrap.padding.top
                bottomMargin: wrap.padding.bottom
            }
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
