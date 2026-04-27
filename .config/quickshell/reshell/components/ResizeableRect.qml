import QtQuick
import qs.core

Rectangle {
    id: resizeableRect
    property int rulersSize: 12
    property bool pointerVisible: true

    border {
        width: pointerVisible ? 2 : 0
        color: Colors.color.tertiary
    }

    color: "transparent"

    Rectangle {
        width: rulersSize
        height: rulersSize
        radius: rulersSize
        color: Colors.color.primary
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.verticalCenter
        opacity: resizeableRect.pointerVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }
        MouseArea {
            anchors.fill: parent
            enabled: resizeableRect.pointerVisible
            hoverEnabled: true
            onHoveredChanged: {
                parent.opacity = 1;
            }
            propagateComposedEvents: true
            drag {
                target: parent
                axis: Drag.XAxis
            }
            onMouseXChanged: {
                if (drag.active) {
                    resizeableRect.width = resizeableRect.width - mouseX;
                    resizeableRect.x = resizeableRect.x + mouseX;
                    if (resizeableRect.width < 30)
                        resizeableRect.width = 30;
                }
            }
        }
    }

    Rectangle {
        width: rulersSize
        height: rulersSize
        radius: rulersSize
        color: Colors.color.primary
        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.verticalCenter
        opacity: resizeableRect.pointerVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            enabled: resizeableRect.pointerVisible
            hoverEnabled: true
            onHoveredChanged: {
                parent.opacity = 1;
            }
            drag {
                target: parent
                axis: Drag.XAxis
            }
            onMouseXChanged: {
                if (drag.active) {
                    resizeableRect.width = resizeableRect.width + mouseX;
                    if (resizeableRect.width < 50)
                        resizeableRect.width = 50;
                }
            }
        }
    }

    Rectangle {
        width: rulersSize
        height: rulersSize
        radius: rulersSize
        x: parent.x / 2
        y: 0
        color: Colors.color.primary
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.top
        opacity: resizeableRect.pointerVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            enabled: resizeableRect.pointerVisible
            hoverEnabled: true
            onHoveredChanged: {
                parent.opacity = 1;
            }
            drag {
                target: parent
                axis: Drag.YAxis
            }

            onMouseYChanged: {
                if (drag.active) {
                    resizeableRect.height = resizeableRect.height - mouseY;
                    resizeableRect.y = resizeableRect.y + mouseY;
                    if (resizeableRect.height < 50)
                        resizeableRect.height = 50;
                }
            }
        }
    }

    Rectangle {
        width: rulersSize
        height: rulersSize
        radius: rulersSize
        x: parent.x / 2
        y: parent.y
        color: Colors.color.primary
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.bottom
        opacity: resizeableRect.pointerVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            enabled: resizeableRect.pointerVisible
            hoverEnabled: true
            onHoveredChanged: {
                parent.opacity = 1;
            }
            drag {
                target: parent
                axis: Drag.YAxis
            }
            onMouseYChanged: {
                if (drag.active) {
                    resizeableRect.height = resizeableRect.height + mouseY;
                    if (resizeableRect.height < 50)
                        resizeableRect.height = 50;
                }
            }
        }
    }
}
