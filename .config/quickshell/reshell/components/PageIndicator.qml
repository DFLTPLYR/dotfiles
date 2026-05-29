import QtQuick
import QtQuick.Controls.Basic
import qs.core

PageIndicator {
    id: control

    property QtObject state: QtObject {
        property int width: 8
        property int height: 8
        property real radius: 4
        property color color: Colors.color.primary
    }
    delegate: Rectangle {
        required property int index

        implicitWidth: control.state.width
        implicitHeight: control.state.height
        radius: control.state.radius
        color: control.state.color
        opacity: index === control.currentIndex ? 0.95 : pressed ? 0.7 : 0.45

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }
    }
}
