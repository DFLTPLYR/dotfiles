import QtQuick
import QtQuick.Controls
import qs.core

Pane {
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    background: Rectangle {
        anchors.fill: parent
        color: Colors.setOpacity(Colors.color.background, 0.5)
    }
}
