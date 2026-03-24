import QtQuick

import qs.core

import QtQuick.Controls.Basic

Button {
    id: control
    property var state: Components.general.button
    hoverEnabled: true
    clip: true

    contentItem: Text {
        id: content
        property var state: control.state.content

        text: control.text
        font: control.font

        color: control.hovered || control.down ? Qt.darker(content.state.color, 1.5) : content.state.color
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

        property var state: control.state.background

        implicitWidth: 40
        implicitHeight: 40

        opacity: enabled ? 1 : 0.3

        border {
            width: background.state.border.width
            color: background.state.border.color
        }

        color: control.hovered || control.down ? Qt.darker(background.state.color, 1.5) : background.state.color

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
            Global.bindRadii(background, background.state.rounding);
        }
    }
}
