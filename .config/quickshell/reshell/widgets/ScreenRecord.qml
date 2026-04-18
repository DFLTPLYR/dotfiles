import Quickshell

import QtQuick

import qs.core
import qs.components

Wrapper {
    id: wrap
    property bool recording: false

    width: wrap.setSize()
    height: wrap.setSize()

    Button {
        id: button
        enabled: Global.normal

        text: "camcorder"
        anchors.fill: parent

        content.color: Colors.color.primary
        font {
            family: Components.icon.family
            weight: Components.icon.weight
            styleName: Components.icon.styleName
            pixelSize: parent ? Math.min(parent.width, parent.height) / 3 : 0
        }
        onClicked: {}
    }
}
