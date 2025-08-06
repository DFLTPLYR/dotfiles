// StyledButton.qml
import qs.assets

import QtQuick 2.15

Rectangle {
    id: root
    width: size
    height: size
    radius: width / 2
    color: hovered ? hoverColor : backgroundColor
    border.color: borderColor
    border.width: 1
    antialiasing: true

    property alias icon: iconText.text
    property int size: 64
    property real iconRatio: 0.5
    property color backgroundColor: "#222"
    property color hoverColor: "#444"
    property color borderColor: "#666"
    property color iconColor: "white"
    property string fontFamily: Font.fontAwesome

    property bool hovered: false
    signal clicked

    Behavior on color {
        ColorAnimation {
            duration: 150
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.InOutQuad
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }

    Text {
        id: iconText
        anchors.centerIn: parent
        text: "\uf04c"
        font.family: fontFamily
        font.pixelSize: root.size * iconRatio
        color: iconColor
    }
}
