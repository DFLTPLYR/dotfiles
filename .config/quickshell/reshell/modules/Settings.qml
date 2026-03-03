import QtQuick

import qs.core

Rectangle {
    id: floatingWindow
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: screen.width / 2
    height: screen.height / 2
    color: Qt.rgba(0, 0, 0, 0.2)
    border {
        width: 1
        color: "white"
    }
    Drag.active: ma.drag.active
    opacity: Global.enableSetting ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        drag.target: floatingWindow
        onReleased: {
            floatingWindow.Drag.drop();
        }
    }

    Rectangle {
        id: floatingWindow2

        width: 20
        height: 20
        color: Qt.rgba(0, 0, 0, 0.2)
        border {
            width: 1
            color: "white"
        }
        Drag.active: ma2.drag.active

        MouseArea {
            id: ma2
            anchors.fill: parent
            drag.target: floatingWindow2
            onReleased: {
                floatingWindow2.Drag.drop();
            }
        }
    }
}
