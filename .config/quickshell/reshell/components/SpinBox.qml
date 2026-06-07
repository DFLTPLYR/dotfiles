import QtQuick
import QtQuick.Controls

import qs.core
import qs.types

SpinBox {
    id: spinbox

    property QtObject config: QtObject {
        property color color: Colors.theme.surface
        property color text: Colors.theme.on_surface
        property Border border: Border {}
        property Direction margin: Direction {}
        property Corner rounding: Corner {}
        property QtObject hover: QtObject {
            property color color: Colors.setOpacity(Colors.theme.primary, 1)
            property Border border: Border {}
            property Direction margin: Direction {}
            property Corner rounding: Corner {}
        }
        property QtObject unhover: QtObject {
            property real opacity: 0.5
            property color color: Colors.setOpacity(Colors.theme.primary, 0.7)
            property Border border: Border {}
            property Direction margin: Direction {}
            property Corner rounding: Corner {}
        }
    }

    editable: true
    wheelEnabled: true
    from: -1e+09
    to: 1e+09

    background: Rectangle {
        id: background

        anchors.fill: parent
        color: spinbox.config.color
        bottomLeftRadius: spinbox.config.rounding.bottomLeft + Components.config.rounding.bottomLeft
        bottomRightRadius: spinbox.config.rounding.bottomRight + Components.config.rounding.bottomRight
        topLeftRadius: spinbox.config.rounding.topLeft + Components.config.rounding.topLeft
        topRightRadius: spinbox.config.rounding.topRight + Components.config.rounding.topRight

        border {
            width: spinbox.config.border.width
            color: spinbox.config.border.color
        }
    }

    contentItem: TextInput {
        text: value
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        color: spinbox.config.text

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: rightIndicator.width + 4
            rightMargin: leftIndicator.width + 4
        }
    }

    up.indicator: Rectangle {
        id: leftIndicator

        property var state: spinbox.up.pressed ? spinbox.config.hover : spinbox.config.unhover

        height: parent.height - 4
        width: height
        y: 2
        color: leftIndicator.state.color
        bottomLeftRadius: leftIndicator.state.rounding.bottomLeft + Components.config.rounding.bottomLeft
        bottomRightRadius: leftIndicator.state.rounding.bottomRight + Components.config.rounding.bottomRight
        topLeftRadius: leftIndicator.state.rounding.topLeft + Components.config.rounding.topLeft
        topRightRadius: leftIndicator.state.rounding.topRight + Components.config.rounding.topRight

        anchors {
            right: parent.right
            rightMargin: 2
        }

        border {
            width: leftIndicator.state.border.width
            color: leftIndicator.state.border.color
        }

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

        property var state: spinbox.down.pressed ? spinbox.config.hover : spinbox.config.unhover

        height: parent.height - 4
        width: height
        y: 2
        color: rightIndicator.state.color
        bottomLeftRadius: rightIndicator.state.rounding.bottomLeft + Components.config.rounding.bottomLeft
        bottomRightRadius: rightIndicator.state.rounding.bottomRight + Components.config.rounding.bottomRight
        topLeftRadius: rightIndicator.state.rounding.topLeft + Components.config.rounding.topLeft
        topRightRadius: rightIndicator.state.rounding.topRight + Components.config.rounding.topRight

        anchors {
            left: parent.left
            leftMargin: 2
        }

        border {
            width: rightIndicator.state.border.width
            color: rightIndicator.state.border.color
        }

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
