import QtQuick

import qs.config
import qs.components

StyledIconButton {
    property string handler
    property bool isSlotted: false
    property bool enableActions: true

    enabled: enableActions

    anchors {
        verticalCenter: parent ? parent.verticalCenter : undefined
    }

    property real widgetWidth
    property real widgetHeight

    width: {
        if (widgetWidth !== 0 && !Config.navbar.side) {
            return widgetWidth;
        }
        return parent ? parent.width : 0;
    }

    height: {
        if (widgetHeight !== 0 && Config.navbar.side) {
            return widgetHeight;
        }
        return parent ? parent.height : 0;
    }

    radius: width

    Text {
        font.family: Config.iconFont.family
        font.weight: Config.iconFont.weight
        font.styleName: Config.iconFont.styleName
        font.pixelSize: Math.min(parent.height, parent.width) / 2

        color: "white"
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        text: "power-off"
    }

    onAction: {
        if (enableActions)
            Config.openSessionMenu = !Config.openSessionMenu;
    }
}
