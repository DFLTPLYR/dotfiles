pragma ComponentBehavior: Bound
import QtQuick
import qs.core

Item {
    id: outline
    property real zoom: 1
    focusPolicy: Qt.NoFocus
    focus: false
    // border
    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }
        height: 2 / outline.zoom
        color: Colors.theme.primary
    }

    Rectangle {
        anchors {
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }
        height: 2 / outline.zoom
        color: Colors.theme.primary
        y: parent.height
    }

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: 2 / outline.zoom
        color: Colors.theme.primary
    }

    Rectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: 2 / outline.zoom
        color: Colors.theme.primary
        x: parent.width
    }
}
