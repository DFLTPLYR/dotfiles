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

    Rectangle {
        anchors.fill: parent
        color: hoverArea.hovered ? Colors.setOpacity(Colors.theme.primary, 0.2) : "transparent"
        radius: width / 2

        Text {
            anchors.fill: parent
            text: "screen_record"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: hoverArea.hovered || ScreenRec.isRunning ? Colors.theme.tertiary : Colors.theme.primary
            font.family: "Material Symbols Rounded"

            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        HoverHandler {
            id: hoverArea
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
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
