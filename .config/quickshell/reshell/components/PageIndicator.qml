import QtQuick
import QtQuick.Controls.Basic

import qs.core

PageIndicator {
    id: control

    property var state: Components.config.pageIndicator

    delegate: Rectangle {
        implicitWidth: control.state.width
        implicitHeight: control.state.height

        radius: control.state.radius
        color: control.state.color

        opacity: index === control.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

        required property int index

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }
    }
}
