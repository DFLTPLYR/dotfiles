// ClockWidget.qml
import QtQuick

import Quickshell
import Quickshell.Widgets

import qs.services
import qs.animations
import qs.modules
import qs.assets

Item {
    id: root
    implicitWidth: clockText.implicitWidth
    height: parent.height

    Text {
        id: clockText
        text: Time.time
        color: Colors.color10
        font.pixelSize: 12
        Fade on text {}
        anchors.verticalCenter: parent.verticalCenter
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            Time.detailed = !Time.detailed;
        }
    }
}
