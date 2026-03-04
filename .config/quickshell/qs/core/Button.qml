import QtQuick

import qs.core

Rectangle {
    id: btn
    readonly property var hover: Global.general.button.hover
    readonly property var unhover: Global.general.button.unhover

    signal clicked(var mouse)

    property var currentState: ma.containsMouse ? hover : unhover

    color: Colors.setOpacity(Colors.color.background, currentState.opacity)

    border {
        width: currentState.border.width
        color: currentState.border.color
    }

    bottomLeftRadius: currentState.rounding.bottomLeft
    bottomRightRadius: currentState.rounding.bottomRight
    topLeftRadius: currentState.rounding.topLeft
    topRightRadius: currentState.rounding.topRight

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

    Behavior on bottomLeftRadius { NumberAnimation { duration: 200 } }
    Behavior on bottomRightRadius { NumberAnimation { duration: 200 } }
    Behavior on topLeftRadius { NumberAnimation { duration: 200 } }
    Behavior on topRightRadius { NumberAnimation { duration: 200 } }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: mouse => btn.clicked(mouse)
    }
}
