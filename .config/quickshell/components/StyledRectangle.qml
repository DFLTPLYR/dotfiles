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

    property alias paddingLeft: rect.anchors.leftMargin
    property alias paddingRight: rect.anchors.rightMargin
    property alias paddingTop: rect.anchors.topMargin
    property alias paddingBottom: rect.anchors.bottomMargin

    property alias roundingTopLeft: rect.topRightRadius
    property alias roundingTopRight: rect.topLeftRadius
    property alias roundingBottomLeft: rect.bottomLeftRadius
    property alias roundingBottomRight: rect.bottomLeftRadius

    property alias backingVisible: backgroundRect.visible
    property alias backingrectX: backgroundRect.x
    property alias backingrectY: backgroundRect.y
    property alias backingrectOpacity: backgroundRect.opacity

    property alias intersectionOpacity: intersectionRect.opacity
    property alias intersectBorder: intersectionRect.border
    property alias intersectionPadding: intersectionRect.anchors.margins
    property alias intersectionColor: intersectionRect.color

    default property alias intersectionContent: intersectionRect.children

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
        visible: layoutHandler.backingrectEnabled
        height: rect.height
        width: rect.width
        radius: rect.radius
        x: layoutHandler.backingrectX
        y: layoutHandler.backingrectY
        opacity: layoutHandler.backingrectOpacity
        color: rect.color
    }

    Rectangle {

        x: Math.max(rect.x, backgroundRect.x)
        y: Math.max(rect.y, backgroundRect.y)
        width: Math.max(0, Math.min(rect.x + rect.width, backgroundRect.x + backgroundRect.width) - Math.max(rect.x, backgroundRect.x))
        height: Math.max(0, Math.min(rect.y + rect.height, backgroundRect.y + backgroundRect.height) - Math.max(rect.y, backgroundRect.y))
        color: rect.color
        opacity: 0.7
        visible: width > 0 && height > 0

        Rectangle {
            id: intersectionRect
            anchors.fill: parent
            color: "green"
            anchors.margins: layoutHandler.rounding
        }
    }
}
