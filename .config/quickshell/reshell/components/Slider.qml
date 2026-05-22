import QtQuick
import QtQuick.Controls.Basic
import qs.core
import qs.types

Slider {
    id: control

    property QtObject config: QtObject {
        property QtObject background: QtObject {
            property int height: 4
            property int width: 200
            property color color: Colors.color.background
            property Corner rounding: Corner {
                topLeft: 100
                topRight: 100
                bottomLeft: 100
                bottomRight: 100
            }
            property Border border: Border {}
            property Direction margin: Direction {}
            property QtObject progress: QtObject {
                property int height: 4
                property int width: 26
                property color color: Colors.color.primary
                property Corner rounding: Corner {
                    topLeft: 100
                    topRight: 100
                    bottomLeft: 100
                    bottomRight: 100
                }
                property Border border: Border {}
                property Direction margin: Direction {}
            }
        }
        property QtObject handle: QtObject {
            property color color: Colors.color.primary
            property int height: 26
            property int width: 26
            property Corner rounding: Corner {
                topLeft: 13
                topRight: 13
                bottomLeft: 13
                bottomRight: 13
            }
            property Border border: Border {}
            property Direction margin: Direction {}
        }
    }

    Component.onCompleted: {
        Global.bindRadii(background, background.state.rounding);
    }

    background: Rectangle {
        id: background

        property var state: control.config.background

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

        Rectangle {
            id: progress

            property var state: control.config.background.progress

            width: control.visualPosition * parent.width
            height: progress.state.height
            color: progress.state.color
            Component.onCompleted: {
                Global.bindRadii(progress, progress.state.rounding);
            }

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
    }

    handle: Rectangle {
        id: handle

        property var state: control.config.handle

        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: handle.state.height
        implicitHeight: handle.state.width
        color: control.pressed ? Qt.darker(handle.state.color, 1.2) : handle.state.color
        Component.onCompleted: {
            Global.bindRadii(handle, handle.state.rounding);
        }

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
    }
}
