import QtQuick

import qs.config
import qs.components

Wrapper {
    id: wrapper
    property string icon: "power-off"
    property int widgetHeight: 50
    property int widgetWidth: 50
    StyledIconButton {
        enabled: wrapper.enableActions !== undefined ? wrapper.enableActions : false

        anchors {
            verticalCenter: parent ? parent.verticalCenter : undefined
        }

        width: {
            return parent ? parent.width : 0;
        }

        height: {
            return parent ? parent.height : 0;
        }

        radius: width

        Text {
            font.family: Config.iconFont.family
            font.weight: Config.iconFont.weight
            font.styleName: Config.iconFont.styleName
            font.pixelSize: Math.min(parent.height, parent.width) / 2

            color: Colors.color.primary

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
}
