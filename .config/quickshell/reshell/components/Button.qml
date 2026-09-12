pragma ComponentBehavior: Bound
import QtQuick

import qs.core
import qs.types
import QtQuick.Controls.Basic

Button {
    id: control
    property alias content: content

    property QtObject config: QtObject {
        property QtObject content: QtObject {
            property color color: Colors.theme.on_surface
        }
        property QtObject background: QtObject {
            property int height: 2
            property int width: 200

            property color color: Colors.theme.surface

            property Border border: Border {}
            property Direction margin: Direction {}
            property Corner rounding: Corner {}
        }
    }

    hoverEnabled: true
    clip: true

    contentItem: Text {
        id: content
        width: parent.width
        height: parent.height
        text: control.text
        font: control.font

        color: control.hovered || control.down ? Qt.darker(control.config.content.color, 1.5) : control.config.content.color
        opacity: enabled ? 1.0 : 0.3

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        elide: Text.ElideRight
        wrapMode: Text.WordWrap

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    background: Rectangle {
        id: background

        implicitWidth: 40
        implicitHeight: 40

        opacity: enabled ? 1 : 0.3

        topLeftRadius: control.config.background.rounding.topLeft
        topRightRadius: control.config.background.rounding.topRight
        bottomLeftRadius: control.config.background.rounding.bottomLeft
        bottomRightRadius: control.config.background.rounding.bottomRight

        border {
            width: control.config.background.border.width
            color: control.config.background.border.color
        }

        color: control.hovered || control.down ? Qt.darker(control.config.background.color, 1.5) : control.config.background.color

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Component.onCompleted: {
            Utils.bindRadii(background, control.config.background.rounding);
        }
    }
}
