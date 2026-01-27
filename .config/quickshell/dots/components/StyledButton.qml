import QtQuick
import QtQuick.Controls

import qs.config

Button {
    id: root
    property color textColor: Colors.palette.neutral100
    property color bgColor: Colors.palette.primary60

    property int borderWidth: 1
    property color borderColor: "transparent"
    property int borderRadius: height / 2
    leftPadding: 10
    rightPadding: 10
    background: Rectangle {
        id: background
        anchors.fill: parent
        radius: root.borderRadius
        color: root.bgColor
        border.width: root.borderWidth
        border.color: root.borderColor

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }
    palette.buttonText: root.textColor
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: mouse => mouse.accepted = false
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.WaitCursor
    }
}
