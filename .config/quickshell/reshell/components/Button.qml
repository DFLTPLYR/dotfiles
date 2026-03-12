import QtQuick

import qs.core

import QtQuick.Controls.Basic

Button {
    id: control
    property var state: control.down ? Components.general.button.hover : Components.general.button.unhover

    contentItem: Text {
        id: content
        property var state: Components.general.button.content

        text: control.text
        font: control.font

        color: control.down ? Qt.darker(content.state.down, 1.5) : content.state.up

        opacity: enabled ? 1.0 : 0.3

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        elide: Text.ElideRight

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    background: Rectangle {
        id: background

        property var state: Components.general.button.background

        implicitWidth: 100
        implicitHeight: 40

        opacity: enabled ? 1 : 0.3

        border {
            width: background.state.border.width
            color: background.state.border.color
        }

        color: control.down ? background.state.up : background.state.down

        bottomLeftRadius: background.state.rounding.bottomLeft
        bottomRightRadius: background.state.rounding.bottomRight
        topLeftRadius: background.state.rounding.topLeft
        topRightRadius: background.state.rounding.topRight

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
    }
}
