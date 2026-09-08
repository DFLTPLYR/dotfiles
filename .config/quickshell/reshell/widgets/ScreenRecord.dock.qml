import QtQuick
import qs.components
import qs.core
import qs.types

import System

Wrapper {
    id: wrap
    property: Property {
        property string path: `/home/dfltplyr/Videos/Record-${Qt.formatDateTime(Global.clock.date, "hh:mm::ss")}.mp4`
    }
    width: wrap.setSize()
    height: wrap.setSize()

    Button {
        id: button

        enabled: Global.normal
        text: "camcorder"
        anchors.fill: parent
        content.color: Colors.theme.primary
        onClicked: proc.running = true

        font {
            family: Components.icon.family
            weight: Components.icon.weight
            styleName: Components.icon.styleName
            pixelSize: parent ? Math.min(parent.width, parent.height) / 3 : 0
        }
    }
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            return;
        if (ScreenRec.isRunning) {
            ScreenRec.stop();
        } else {
            ScreenRec.start(property.path);
        }
    }
}
