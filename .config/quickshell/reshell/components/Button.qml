pragma ComponentBehavior: Bound
import QtQuick

import qs.core

import QtQuick.Controls.Basic

Button {
    id: control
    property var conf: Components.config?.button
    property alias content: content
    hoverEnabled: true
    clip: true

    contentItem: Text {
        id: content
        property var conf: Components.config?.button.content
        width: parent.width
        text: control.text
        font: control.font

        color: control.hovered || control.down ? Qt.darker(content?.conf?.color, 1.5) : content?.conf?.color
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

        property var conf: Components.config?.button.background

        implicitWidth: 40
        implicitHeight: 40

        opacity: enabled ? 1 : 0.3

        border {
            width: background.conf.border.width
            color: background.conf.border.color
        }

        color: control.hovered || control.down ? Qt.darker(background.conf.color, 1.5) : background.conf.color

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
            Global.bindRadii(background, background.conf.rounding);
        }
    }
}
