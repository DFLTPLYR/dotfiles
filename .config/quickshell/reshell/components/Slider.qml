import QtQuick
import QtQuick.Controls.Basic

import qs.core

Slider {
    id: control
    property var state: Components.config.slider

    background: Rectangle {
        id: background
        property var state: control.state.background

        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2

        implicitWidth: background.state.width
        implicitHeight: background.state.height

        width: control.availableWidth
        height: implicitHeight

        color: background.state.color

        border {
            width: background.state.border.width
            color: background.state.border.color
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: progress
            property var state: control.state.background.progress
            width: control.visualPosition * parent.width
            height: progress.state.height
            color: progress.state.color

            border {
                width: progress.state.border.width
                color: progress.state.border.color
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            Component.onCompleted: {
                Global.bindRadii(progress, progress.state.rounding);
            }
        }
    }

    handle: Rectangle {
        id: handle
        property var state: control.state.handle
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2

        implicitWidth: handle.state.height
        implicitHeight: handle.state.width

        color: control.pressed ? Qt.darker(handle.state.color, 1.2) : handle.state.color

        border {
            width: handle.state.border.width
            color: handle.state.border.color
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on x {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        Component.onCompleted: {
            Global.bindRadii(handle, handle.state.rounding);
        }
    }

    Component.onCompleted: {
        Global.bindRadii(background, background.state.rounding);
    }
}
