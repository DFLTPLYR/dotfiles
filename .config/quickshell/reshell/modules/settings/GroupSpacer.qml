pragma ComponentBehavior: Bound
import QtQuick
import qs.core

Item {
    anchors {
        left: parent.left
        leftMargin: parent.padding
        right: parent.right
        rightMargin: parent.padding
    }
    height: 20

    Rectangle {
        width: parent.width
        height: 2
        color: Qt.darker(Colors.theme.surface, 1.2)
        anchors {
            centerIn: parent
        }
    }
}
