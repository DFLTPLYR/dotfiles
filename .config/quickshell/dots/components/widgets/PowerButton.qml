import QtQuick

import qs.config
import qs.utils

Wrapper {
    id: wrapper
    property string icon: "power-off"
    property int widgetHeight: 50
    property int widgetWidth: 50

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            Config.openSessionMenu = !Config.openSessionMenu;
        }
        onHoveredChanged: {
            if (containsMouse) {
                background.color = Colors.color.secondary;
            } else {
                background.color = Scripts.setOpacity(Colors.color.on_primary, 0.8);
            }
        }
    }

    Text {
        font.family: Config.iconFont.family
        font.weight: Config.iconFont.weight
        font.styleName: Config.iconFont.styleName
        font.pixelSize: Math.min(parent.height, parent.width)

        color: ma.containsMouse ? Colors.color.on_secondary : Colors.color.primary

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        text: wrapper.icon
    }
}
