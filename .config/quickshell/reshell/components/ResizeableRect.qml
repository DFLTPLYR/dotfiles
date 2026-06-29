import QtQuick
import qs.core

Pane {
    id: container
    clip: false
    signal resized
    property alias bg: background
    property int rulersSize: 12
    property bool pointerVisible: true

    Rectangle {
        id: leftHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.verticalCenter
        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: leftHandleArea.containsMouse && !leftHandleArea.drag.active

                PropertyChanges {
                    target: leftHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: leftHandleArea.drag.active

                PropertyChanges {
                    target: leftHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: leftHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseXChanged: {
                if (drag.active) {
                    container.width = container.width - mouseX;
                    container.x = container.x + mouseX;
                    if (container.width < 30)
                        container.width = 30;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.XAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: rightHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.verticalCenter
        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: rightHandleArea.containsMouse && !rightHandleArea.drag.active

                PropertyChanges {
                    target: rightHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: rightHandleArea.drag.active

                PropertyChanges {
                    target: rightHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: rightHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseXChanged: {
                if (drag.active) {
                    container.width = container.width + mouseX;
                    if (container.width < 50)
                        container.width = 50;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.XAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: topHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        x: parent.x / 2
        y: 0
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.top
        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: topHandleArea.containsMouse && !topHandleArea.drag.active

                PropertyChanges {
                    target: topHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: topHandleArea.drag.active

                PropertyChanges {
                    target: topHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: topHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseYChanged: {
                if (drag.active) {
                    container.height = container.height - mouseY;
                    container.y = container.y + mouseY;
                    if (container.height < 50)
                        container.height = 50;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.YAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: bottomHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        x: parent.x / 2
        y: parent.y
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.bottom
        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: bottomHandleArea.containsMouse && !bottomHandleArea.drag.active

                PropertyChanges {
                    target: bottomHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: bottomHandleArea.drag.active

                PropertyChanges {
                    target: bottomHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: bottomHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseYChanged: {
                if (drag.active) {
                    container.height = container.height + mouseY;
                    if (container.height < 50)
                        container.height = 50;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.YAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    // Corners
    Rectangle {
        id: topRightHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.top

        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: topRightHandleArea.containsMouse && !topRightHandleArea.drag.active

                PropertyChanges {
                    target: topRightHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: topRightHandleArea.drag.active

                PropertyChanges {
                    target: topRightHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: topRightHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseYChanged: {
                if (drag.active) {
                    container.height = container.height - mouseY;
                    container.y = container.y + mouseY;
                    if (container.height < 50)
                        container.height = 50;

                    container.width = container.width + mouseX;
                    if (container.width < 50)
                        container.width = 50;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.YAxis | Drag.XAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: topLeftHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.top

        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: topLeftHandleArea.containsMouse && !topRightHandleArea.drag.active

                PropertyChanges {
                    target: topLeftHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: topLeftHandleArea.drag.active

                PropertyChanges {
                    target: topLeftHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: topLeftHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseYChanged: {
                if (drag.active) {
                    container.height = container.height - mouseY;
                    container.y = container.y + mouseY;

                    container.width = container.width - mouseX;
                    container.x = container.x + mouseX;
                    if (container.width < 50)
                        container.width = 50;
                    if (container.height < 50)
                        container.height = 50;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.YAxis | Drag.XAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: bottomRightHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.bottom

        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: bottomRightHandleArea.containsMouse && !bottomRightHandleArea.drag.active

                PropertyChanges {
                    target: bottomRightHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: bottomRightHandleArea.drag.active

                PropertyChanges {
                    target: bottomRightHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: bottomRightHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseYChanged: {
                if (drag.active) {
                    container.height = container.height + mouseY;
                    container.width = container.width + mouseX;
                    if (container.height < 50)
                        container.height = 50;

                    if (container.width < 50)
                        container.width = 50;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.YAxis | Drag.XAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    Rectangle {
        id: bottomLeftHandle

        width: container.rulersSize
        height: container.rulersSize
        radius: container.rulersSize
        color: Colors.theme.primary
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.bottom

        opacity: container.pointerVisible ? 1 : 0
        states: [
            State {
                name: "hovered"
                when: bottomLeftHandleArea.containsMouse && !bottomRightHandleArea.drag.active

                PropertyChanges {
                    target: bottomLeftHandle
                    color: Colors.theme.secondary
                }
            },
            State {
                name: "dragging"
                when: bottomLeftHandleArea.drag.active

                PropertyChanges {
                    target: bottomLeftHandle
                    color: Colors.theme.tertiary
                }
            }
        ]

        MouseArea {
            id: bottomLeftHandleArea

            anchors.fill: parent
            enabled: container.pointerVisible
            hoverEnabled: true
            onMouseYChanged: {
                if (drag.active) {
                    container.height = container.height + mouseY;
                    container.width = container.width - mouseX;
                    container.x = container.x + mouseX;
                    if (container.height < 50)
                        container.height = 50;
                    if (container.width < 50)
                        container.width = 50;
                }
            }

            onReleased: mouse => {
                container.resized();
            }

            drag {
                target: parent
                axis: Drag.YAxis | Drag.XAxis
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }
    }

    background: Rectangle {
        id: background

        anchors.fill: parent
        color: "transparent"

        border {
            width: container.pointerVisible ? 2 : 0
            color: Colors.theme.tertiary
        }
    }
}
