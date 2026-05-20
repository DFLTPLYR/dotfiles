import QtQuick
import QtQuick.Controls
import qs.core

Pane {
    property alias bg: background

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    background: Rectangle {
        id: background

        anchors.fill: parent
        color: Colors.setOpacity(Colors.color.background, 0.5)
    }
}
