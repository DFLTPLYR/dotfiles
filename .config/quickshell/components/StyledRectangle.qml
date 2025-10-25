import QtQuick
import Quickshell.Io

import qs.utils
import qs.assets

Item {
    id: layoutHandler

    property alias bgColor: rect.color
    property alias transparency: rect.opacity
    property alias rounding: rect.radius
    property alias padding: rect.anchors.margins

    property alias backingVisible: backgroundRect.visible
    property alias backingRectX: backgroundRect.x
    property alias backingRectY: backgroundRect.y
    property alias backingRectOpacity: backgroundRect.opacity

    property alias intersectionVisible: intersectionRect.visible
    property alias intersectBorder: intersectionRect.border

    Rectangle {
        id: rect
        height: parent.height
        width: parent.width
        opacity: layoutHandler.opacity
        anchors.margins: 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Rectangle {
        id: backgroundRect
        visible: layoutHandler.backingRectEnabled
        height: rect.height
        width: rect.width
        radius: rect.radius
        x: layoutHandler.backingRectX
        y: layoutHandler.backingRectY
        opacity: layoutHandler.backingRectOpacity
        color: rect.color
    }

    Rectangle {
        id: intersectionRect

        x: Math.max(rect.x, backgroundRect.x)
        y: Math.max(rect.y, backgroundRect.y)
        width: Math.max(0, Math.min(rect.x + rect.width, backgroundRect.x + backgroundRect.width) - Math.max(rect.x, backgroundRect.x))
        height: Math.max(0, Math.min(rect.y + rect.height, backgroundRect.y + backgroundRect.height) - Math.max(rect.y, backgroundRect.y))
        color: rect.color
        opacity: 0.7
        visible: layoutHandler.backingRectShowIntersection && width > 0 && height > 0

        border.color: "green"
        border.width: 2
    }
}
