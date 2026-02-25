import QtQuick

import qs.utils
import qs.config

Item {
    id: wrap

    default property alias content: contentItem.data
    property alias background: background

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
        radius: wrap.rouding + Config.general.appearance.rounding
        clip: true

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        anchors {
            fill: parent
            topMargin: wrap.margin.top + Config.general.appearance.margin
            bottomMargin: wrap.margin.bottom + Config.general.appearance.margin
            leftMargin: wrap.margin.left + Config.general.appearance.margin
            rightMargin: wrap.margin.right + Config.general.appearance.margin
        }

        // content area with padding applied
        BorderImage {
            id: contentItem
            clip: true
            anchors {
                fill: parent
                leftMargin: wrap.padding.left + Config.general.appearance.padding
                rightMargin: wrap.padding.right + Config.general.appearance.padding
                topMargin: wrap.padding.top + Config.general.appearance.padding
                bottomMargin: wrap.padding.bottom + Config.general.appearance.padding
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
