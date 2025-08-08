import QtQuick
import Quickshell

import qs
import qs.services
import qs.animations
import qs.modules

Item {
    id: root
    implicitWidth: systemTempStatus.implicitWidth
    height: parent.height

    Text {
        id: systemTempStatus
        visible: true
        text: 'test'
        color: Colors.color14

        font.pixelSize: Appearance.fontsize
        font.family: "monospace"
        Fade on text {}

        anchors.verticalCenter: parent.verticalCenter
    }
}
