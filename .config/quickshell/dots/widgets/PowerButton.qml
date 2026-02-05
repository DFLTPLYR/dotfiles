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

    width: parent ? parent.height / 1.5 : 0
    height: parent ? parent.height / 1.5 : 0
    radius: parent ? width / 2 : 0

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
