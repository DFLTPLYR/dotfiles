pragma ComponentBehavior: Bound

import QtQuick

import qs.types
import qs.core

Pane {
    id: pane
    property alias bg: background

    property QtObject style: QtObject {
        property color color: Colors.setOpacity(Colors.color.background, 0.5)
        property Direction padding: Direction {}
        property Direction inset: Direction {}

        property QtObject background: QtObject {
            property Corner rounding: Corner {}
            property Direction margins: Direction {}
        }
    }

    // margins
    leftInset: pane.style.inset.left
    rightInset: pane.style.inset.right
    topInset: pane.style.inset.top
    bottomInset: pane.style.inset.bottom

    // padding
    leftPadding: pane.style.padding.left
    rightPadding: pane.style.padding.right
    topPadding: pane.style.padding.top
    bottomPadding: pane.style.padding.bottom

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: pane.style.color

        // rounding
        bottomRightRadius: pane.style.background.rounding.bottomRight
        bottomLeftRadius: pane.style.background.rounding.bottomLeft
        topRightRadius: pane.style.background.rounding.topRight
        topLeftRadius: pane.style.background.rounding.topLeft

        // margins
        anchors {
            leftMargin: pane.style.background.margins.left
            rightMargin: pane.style.background.margins.right
            bottomMargin: pane.style.background.margins.bottom
            topMargin: pane.style.background.margins.top
        }
    }
}
