import QtQuick
import QtQuick.Controls.Basic
import qs.core

RangeSlider {
    id: control
    first.value: 0.25
    second.value: 0.75

    background: Rectangle {
        id: background
        property var state: Global.general.range.background

        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2

        implicitWidth: background.state.width
        implicitHeight: background.state.height

        width: control.availableWidth
        height: implicitHeight

        bottomLeftRadius: background.state.rounding.bottomLeft
        bottomRightRadius: background.state.rounding.bottomRight
        topLeftRadius: background.state.rounding.topLeft
        topRightRadius: background.state.rounding.topRight

        color: background.state.color

        Rectangle {
            id: indicator
            x: control.first.visualPosition * parent.width
            width: control.second.visualPosition * parent.width - x
            height: parent.height

            color: background.state.indicator.color

            bottomLeftRadius: background.state.indicator.rounding.bottomLeft
            bottomRightRadius: background.state.indicator.rounding.bottomRight
            topLeftRadius: background.state.indicator.rounding.topLeft
            topRightRadius: background.state.indicator.rounding.topRight
        }
    }

    first.handle: Rectangle {
        id: first
        property var state: Global.general.range.first
        x: control.leftPadding + control.first.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2

        implicitWidth: 26
        implicitHeight: 26

        color: control.first.pressed ? Qt.darker(first.state.color, 1.2) : first.state.color

        border {
            width: first.state.border.width
            color: first.state.border.color
        }

        bottomLeftRadius: first.state.rounding.bottomLeft
        bottomRightRadius: first.state.rounding.bottomRight
        topLeftRadius: first.state.rounding.topLeft
        topRightRadius: first.state.rounding.topRight
    }

    second.handle: Rectangle {
        id: second
        property var state: Global.general.range.second
        x: control.leftPadding + control.second.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2

        implicitWidth: 26
        implicitHeight: 26

        color: control.second.pressed ? Qt.darker(second.state.color, 1.2) : second.state.color

        border {
            width: second.state.border.width
            color: second.state.border.color
        }

        bottomLeftRadius: second.state.rounding.bottomLeft
        bottomRightRadius: second.state.rounding.bottomRight
        topLeftRadius: second.state.rounding.topLeft
        topRightRadius: second.state.rounding.topRight
    }
}
