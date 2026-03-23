import QtQuick
import QtQuick.Controls.Basic

import qs.core

Label {
    id: control
    property var state: Components.general.label

    color: control.state.text

    background: Rectangle {
        id: background
        implicitWidth: control.state.background.width
        implicitHeight: control.state.background.height

        color: control.state.background.color

        border {
            width: control.state.background.border.width
            color: control.state.background.border.color
        }

        Component.onCompleted: {
            Global.bindRadii(background, control.state.background.rounding);
        }
    }
}
