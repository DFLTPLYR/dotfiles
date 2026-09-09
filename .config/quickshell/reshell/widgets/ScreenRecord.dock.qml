import Quickshell
import QtQuick
import qs.components
import qs.core
import qs.types

import System

Wrapper {
    id: wrap
    property: Property {
        property string path: `${Quickshell.env("HOME")}/Videos/Record-${Qt.formatDateTime(Global.clock.date, "hh:mm::ss")}.mp4`
    }

    width: wrap.setWidth(container.width)
    height: wrap.setHeight(container.height)

    Row {
        id: container
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: Utils.formatTime(ScreenRec.elapsed)
            visible: ScreenRec.isRunning
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Colors.theme.primary
            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Text {
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
