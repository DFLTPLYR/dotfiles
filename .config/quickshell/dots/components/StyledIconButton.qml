import QtQuick

Rectangle {
    id: root

    property color unHoveredColor: "transparent"
    property color hoveredColor: Qt.rgba(1, 1, 1, 0.2)
    property int duration: 200

    signal action()

    color: menuBtnArea.containsMouse ? hoveredColor : unHoveredColor

    MouseArea {
        id: menuBtnArea

        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.action();
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: duration
        }

    }

}
