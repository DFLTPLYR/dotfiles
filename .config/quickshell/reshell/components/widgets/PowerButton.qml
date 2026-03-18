import QtQuick
import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.components

Wrapper {
    id: wrap
    // properties
    objectName: "PowerButton"
    setHeight: 50
    setWidth: 50
    relativeX: 0
    relativeY: 0
    position: -1
    // properties

    Button {
        hoverEnabled: true
        enabled: !wrap.active
        anchors {
            fill: parent
            margins: 2
        }
        Icon {
            text: "power-off"
            anchors.centerIn: parent
            color: Colors.color.primary
            font.pixelSize: Math.min(wrap.width, wrap.height) * 0.8
        }
        onClicked: {
            Quickshell.execDetached({
                command: ["sh", "-c", "systemctl poweroff"]
            });
        }
    }
}
