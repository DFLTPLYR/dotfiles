pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic

import qs.core

Label {
    id: control

    property QtObject config: QtObject {
        property QtObject content: QtObject {
            property color color: Colors.theme.on_surface
        }
        property QtObject background: QtObject {
            property int height: 2
            property int width: 200
            property color color: "transparent"
        }
    }
    color: control.config.content.color

    font.capitalization: Font.Capitalize
    background: Rectangle {
        id: background
        implicitWidth: control.width
        implicitHeight: control.height

        color: control.config.background.color
    }
}
