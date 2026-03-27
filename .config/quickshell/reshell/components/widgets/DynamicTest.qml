import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.core
import qs.components

Wrapper {
    id: wrap
    // properties
    objectName: "DynamicTest"
    dynamicsize: true
    position: -1
    // properties

    width: wrap.side ? wrap.defaultsize : container.implicitWidth
    height: wrap.defaultsize

    Rectangle {
        id: container
        width: wrap.width
        height: wrap.height
    }
}
