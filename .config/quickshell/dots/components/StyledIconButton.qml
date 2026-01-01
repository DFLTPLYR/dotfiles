import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    signal action
    property color unHoveredColor: "transparent"
    property color hoveredColor: Qt.rgba(1, 1, 1, 0.2)
    property int duration: 200
    color: menuBtnArea.containsMouse ? hoveredColor : unHoveredColor

    Behavior on color {
        ColorAnimation {
            duration: duration
        }
    }

    MouseArea {
        id: menuBtnArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.action();
        }
    }
}
