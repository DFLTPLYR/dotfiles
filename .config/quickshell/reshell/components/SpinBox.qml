import QtQuick
import QtQuick.Controls

import qs.core

SpinBox {
    id: spinbox

    property var state: Components.general.spinbox

    editable: false
    wheelEnabled: true

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: spinbox.state.color

        border {
            width: spinbox.state.border.width
            color: spinbox.state.border.color
        }

        bottomLeftRadius: spinbox.state.rounding.bottomLeft + Global.general.rounding.bottomLeft
        bottomRightRadius: spinbox.state.rounding.bottomRight + Global.general.rounding.bottomRight
        topLeftRadius: spinbox.state.rounding.topLeft + Global.general.rounding.topLeft
        topRightRadius: spinbox.state.rounding.topRight + Global.general.rounding.topRight
    }

    contentItem: TextInput {
        text: value

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: rightIndicator.width + 4
            rightMargin: leftIndicator.width + 4
        }

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font.pixelSize: 16

        color: spinbox.state.text
    }

    up.indicator: Rectangle {
        id: leftIndicator
        property var state: spinbox.up.pressed ? Components.general.spinbox.hover : Components.general.spinbox.unhover

        height: parent.height - 4
        width: height
        y: 2

        color: leftIndicator.state.color

        anchors {
            right: parent.right
            rightMargin: 2
        }

        border {
            width: leftIndicator.state.border.width
            color: leftIndicator.state.border.color
        }

        bottomLeftRadius: leftIndicator.state.rounding.bottomLeft + Global.general.rounding.bottomLeft
        bottomRightRadius: leftIndicator.state.rounding.bottomRight + Global.general.rounding.bottomRight
        topLeftRadius: leftIndicator.state.rounding.topLeft + Global.general.rounding.topLeft
        topRightRadius: leftIndicator.state.rounding.topRight + Global.general.rounding.topRight

        Icon {
            text: "plus"
            font.pixelSize: Math.min(parent.height, parent.width) * 0.8
            anchors.centerIn: parent
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    down.indicator: Rectangle {
        id: rightIndicator
        property var state: spinbox.down.pressed ? Components.general.spinbox.hover : Components.general.spinbox.unhover

        height: parent.height - 4
        width: height
        y: 2

        color: rightIndicator.state.color

        anchors {
            left: parent.left
            leftMargin: 2
        }

        border {
            width: rightIndicator.state.border.width
            color: rightIndicator.state.border.color
        }

        bottomLeftRadius: rightIndicator.state.rounding.bottomLeft + Global.general.rounding.bottomLeft
        bottomRightRadius: rightIndicator.state.rounding.bottomRight + Global.general.rounding.bottomRight
        topLeftRadius: rightIndicator.state.rounding.topLeft + Global.general.rounding.topLeft
        topRightRadius: rightIndicator.state.rounding.topRight + Global.general.rounding.topRight

        Icon {
            text: "minus"
            font.pixelSize: Math.min(parent.height, parent.width) * 0.8
            anchors.centerIn: parent
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
}
