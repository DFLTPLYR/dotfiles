// ClockWidget.qml
import QtQuick
import Quickshell
import qs.services
import qs.animations
import qs.modules

Item {
    id: root
    implicitWidth: clockText.implicitWidth
    height: parent.height

    Text {
        id: clockText
        text: Time.time
        color: Colors.color14
        font.pixelSize: Appearance.fontsize
        font.family: "monospace"
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
