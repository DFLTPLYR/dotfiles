import QtQuick

import qs.config

Wrapper {
    id: wrapper
    property string icon: "power-off"
    property int widgetHeight: 50
    property int widgetWidth: 50
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            Config.openSessionMenu = !Config.openSessionMenu;
        }
    }
    Text {
        font.family: Config.iconFont.family
        font.weight: Config.iconFont.weight
        font.styleName: Config.iconFont.styleName
        font.pixelSize: Math.min(parent.height, parent.width)

        color: Colors.color.primary

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        text: "power-off"
    }
}
