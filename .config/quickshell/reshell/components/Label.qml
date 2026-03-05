import QtQuick
import QtQuick.Controls.Basic

import qs.core

Label {
    id: control
    property var state: Global.general.label

    color: control.state.text

    background: Rectangle {
        implicitWidth: control.state.background.width
        implicitHeight: control.state.background.height

        color: control.state.background.color

        border {
            width: control.state.background.border.width
            color: control.state.background.border.color
        }

        bottomLeftRadius: control.state.background.rounding.bottomLeft
        bottomRightRadius: control.state.background.rounding.bottomRight
        topLeftRadius: control.state.background.rounding.topLeft
        topRightRadius: control.state.background.rounding.topRight
    }
}
