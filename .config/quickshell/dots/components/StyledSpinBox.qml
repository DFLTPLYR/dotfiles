import QtQuick
import QtQuick.Controls

import qs.config
import qs.components
import qs.utils

SpinBox {
    id: root
    editable: true
    wheelEnabled: true
    width: 100
    height: 30

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: Scripts.setOpacity(Colors.color.background, 0.5)
        radius: height / 2
    }

    contentItem: TextInput {
        text: value
        anchors.left: leftIndicator.right
        anchors.right: rightIndicator.left
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: Math.min(parent.height, parent.width) / 2
        color: Colors.color.secondary
    }

    up.indicator: Rectangle {
        id: leftIndicator
        height: parent.height
        anchors {
            left: parent.left
        }
        radius: height / 2
        implicitWidth: height
        color: root.down.pressed ? Colors.color.primary : Colors.color.secondary

        FontIcon {
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
        height: parent.height
        anchors {
            right: parent.right
        }
        implicitWidth: height
        color: root.down.pressed ? Colors.color.primary : Colors.color.secondary

        radius: height / 2

        FontIcon {
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
