pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic

import qs.core

Label {
    id: control

    property QtObject config: QtObject {
        property QtObject content: QtObject {
            property color color: Colors.color.on_background
        }
        property QtObject background: QtObject {
            property int height: 2
            property int width: 200
            property color color: Colors.color.background
        }
    }
    color: control.config.content.color

    background: Rectangle {
        id: background
        implicitWidth: control.width
        implicitHeight: control.height

        color: control.config.background.color
    }
}
