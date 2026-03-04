import QtQuick
import QtQuick.Controls.Basic

import qs.core

Slider {
    id: control
    property var state: Global.general.slider
    background: Rectangle {
        id: background
        property var state: control.state.background
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: background.state.width
        implicitHeight: background.state.height

        width: control.availableWidth
        height: implicitHeight

        radius: background.state.radius
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

        Rectangle {
            id: progress
            width: control.visualPosition * parent.width
            height: background.state.progress.height
            color: background.state.progress.color
            radius: background.state.progress.radius

            border {
                width: background.state.progress.border.width
                color: background.state.progress.border.color
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
        }
    }

    handle: Rectangle {
        id: handle
        property var state: control.state.handle
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
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
    }
}
