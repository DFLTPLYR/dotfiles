pragma ComponentBehavior: Bound

import QtQuick
import qs.types

Pane {
    id: pane
    property QtObject style: QtObject {
        property Corner rounding: Corner {}
        property Direction margins: Direction {}
        property Direction padding: Direction {}
        property Direction inset: Direction {}
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
        anchors.fill: parent

        // rounding
        bottomRightRadius: pane.style.rounding.bottomRight
        bottomLeftRadius: pane.style.rounding.bottomLeft
        topRightRadius: pane.style.rounding.topRight
        topLeftRadius: pane.style.rounding.topLeft

        // margins
        anchors {
            leftMargin: pane.style.margin.left
            rightMargin: pane.style.margin.right
            bottomMargin: pane.style.margin.bottom
            topMargin: pane.style.margin.top
        }
    }
}
