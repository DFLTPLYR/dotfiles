import QtQuick

import qs.core

import QtQuick.Controls.Basic

Button {
    id: control
    property var config: Components.config?.button
    property alias content: content
    hoverEnabled: true
    clip: true

    contentItem: Text {
        id: content
        property var config: control.config.content
        width: parent.width
        text: control.text
        font: control.font

        color: control.hovered || control.down ? Qt.darker(content?.config?.color, 1.5) : content?.config?.color
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

        property var config: control.config.background

        implicitWidth: 40
        implicitHeight: 40

        opacity: enabled ? 1 : 0.3

        border {
            width: background.config.border.width
            color: background.config.border.color
        }

        color: control.hovered || control.down ? Qt.darker(background.config.color, 1.5) : background.config.color

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
            Global.bindRadii(background, background.config.rounding);
        }
    }
}
