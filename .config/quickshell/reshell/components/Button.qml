import QtQuick

import qs.core

Rectangle {
    id: btn
    property var state: ma.containsMouse ? Global.general.button.hover : Global.general.button.unhover
    signal clicked(var mouse)

    color: btn.state.color

    border {
        width: btn.state.border.width
        color: btn.state.border.color
    }

    bottomLeftRadius: btn.state.rounding.bottomLeft
    bottomRightRadius: btn.state.rounding.bottomRight
    topLeftRadius: btn.state.rounding.topLeft
    topRightRadius: btn.state.rounding.topRight

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: mouse => btn.clicked(mouse)
    }
}
