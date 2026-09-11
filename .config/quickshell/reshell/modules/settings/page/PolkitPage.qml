pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

Page {
    id: page

    GroupContainer {
        label: "Notification Section"

        Rectangle {
            id: exampleNotif
            color: Colors.theme.on_surface
            radius: 5
            height: page.height * 0.4

            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }

            Content {}
        }
    }

    GroupContainer {
        label: "Data"

        Flickable {
            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }
            height: page.height * 0.4
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
        }
    }

    component Grid: Canvas {
        clip: false
        onPaint: {
            var ctx = getContext("2d");
            var gridSize = 10;

            ctx.strokeStyle = Colors.setOpacity(Colors.theme.on_primary, 0.5);
            ctx.lineWidth = 1;

            for (var x = 0; x <= width; x += gridSize) {
                ctx.beginPath();
                ctx.moveTo(x, 0);
                ctx.lineTo(x, height);
                ctx.stroke();
            }

            for (var y = 0; y <= height; y += gridSize) {
                ctx.beginPath();
                ctx.moveTo(0, y);
                ctx.lineTo(width, y);
                ctx.stroke();
            }
        }
    }

    component Content: Flickable {
        id: content
        property var focused
        property QtObject component: QtObject {
            property int width: 300
            property int height: 200
        }

        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        focus: true
        acceptedButtons: Qt.MiddleButton | Qt.LeftButton
        clip: true

        contentX: (contentWidth - width) / 2
        contentY: (contentHeight - height) / 2
        transformOrigin: Item.Center

        Grid {
            anchors.fill: parent
        }

        onDragStarted: {
            focused = null;
        }

        Rectangle {
            id: container
            readonly property bool focused: content.focused === container
            property bool edit: true
            property int handlerSize: 12
            property point pressPos
            property int pressX
            property int pressY
            property int pressW
            property int pressH

            width: content.component.width
            height: content.component.height
            color: "transparent"

            border {
                width: 2
                color: Colors.theme.outline
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.LeftButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        if (menu.opened) {
                            return menu.close();
                        }
                        menu.x = mouse.x;
                        menu.y = mouse.y;
                        menu.open();
                    } else {
                        content.focused = container;
                    }
                }
            }

            Menu {
                id: menu
            }

            function grabPress(area, mx, my) {
                pressPos = area.mapToGlobal(mx, my);
                pressX = container.x;
                pressY = container.y;
                pressW = content.component.width;
                pressH = content.component.height;
            }

            function globalDelta(area, mx, my) {
                const gp = area.mapToGlobal(mx, my);
                return Qt.point(gp.x - pressPos.x, gp.y - pressPos.y);
            }

            // Sides
            Rectangle {
                id: leftHandle
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.verticalCenter
                states: [
                    State {
                        name: "hovered"
                        when: leftHandleArea.containsMouse && !leftHandleArea.pressed

                        PropertyChanges {
                            target: leftHandle
                            color: Colors.theme.secondary
                        }
                    },
                    State {
                        name: "dragging"
                        when: leftHandleArea.pressed

                        PropertyChanges {
                            target: leftHandle
                            color: Colors.theme.tertiary
                        }
                    }
                ]

                MouseArea {
                    id: leftHandleArea

                    cursorShape: Qt.SizeHorCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(leftHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(leftHandleArea, mouse.x, mouse.y);
                        const newW = Math.max(30, container.pressW - d.x);
                        content.component.width = newW;
                        container.x = container.pressX + container.pressW - newW;
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
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.verticalCenter
                states: [
                    State {
                        name: "hovered"
                        when: rightHandleArea.containsMouse && !rightHandleArea.pressed

                        PropertyChanges {
                            target: rightHandle
                            color: Colors.theme.secondary
                        }
                    },
                    State {
                        name: "dragging"
                        when: rightHandleArea.pressed

                        PropertyChanges {
                            target: rightHandle
                            color: Colors.theme.tertiary
                        }
                    }
                ]

                MouseArea {
                    id: rightHandleArea

                    cursorShape: Qt.SizeHorCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(rightHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(rightHandleArea, mouse.x, mouse.y);
                        content.component.width = Math.max(50, container.pressW + d.x);
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
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.top
                states: [
                    State {
                        name: "hovered"
                        when: topHandleArea.containsMouse && !topHandleArea.pressed

                        PropertyChanges {
                            topHandle {
                                color: Colors.theme.secondary
                            }
                        }
                    },
                    State {
                        name: "dragging"
                        when: topHandleArea.pressed

                        PropertyChanges {
                            topHandle {
                                color: Colors.theme.tertiary
                            }
                        }
                    }
                ]

                MouseArea {
                    id: topHandleArea

                    cursorShape: Qt.SizeVerCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(topHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(topHandleArea, mouse.x, mouse.y);
                        const newH = Math.max(50, container.pressH - d.y);
                        content.component.height = newH;
                        container.y = container.pressY + container.pressH - newH;
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
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.bottom
                states: [
                    State {
                        name: "hovered"
                        when: bottomHandleArea.containsMouse && !bottomHandleArea.pressed

                        PropertyChanges {
                            bottomHandle {
                                color: Colors.theme.secondary
                            }
                        }
                    },
                    State {
                        name: "dragging"
                        when: bottomHandleArea.pressed

                        PropertyChanges {
                            bottomHandle {
                                color: Colors.theme.tertiary
                            }
                        }
                    }
                ]

                MouseArea {
                    id: bottomHandleArea
                    cursorShape: Qt.SizeVerCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(bottomHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(bottomHandleArea, mouse.x, mouse.y);
                        content.component.height = Math.max(50, container.pressH + d.y);
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
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.top

                states: [
                    State {
                        name: "hovered"
                        when: topRightHandleArea.containsMouse && !topRightHandleArea.pressed

                        PropertyChanges {
                            topRightHandle {
                                color: Colors.theme.secondary
                            }
                        }
                    },
                    State {
                        name: "dragging"
                        when: topRightHandleArea.pressed

                        PropertyChanges {
                            topRightHandle {
                                color: Colors.theme.tertiary
                            }
                        }
                    }
                ]

                MouseArea {
                    id: topRightHandleArea

                    cursorShape: Qt.SizeBDiagCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(topRightHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(topRightHandleArea, mouse.x, mouse.y);
                        const newW = Math.max(50, container.pressW + d.x);
                        const newH = Math.max(50, container.pressH - d.y);
                        content.component.width = newW;
                        content.component.height = newH;
                        container.y = container.pressY + container.pressH - newH;
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
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.top

                states: [
                    State {
                        name: "hovered"
                        when: topLeftHandleArea.containsMouse && !topLeftHandleArea.pressed

                        PropertyChanges {
                            topLeftHandle {
                                color: Colors.theme.secondary
                            }
                        }
                    },
                    State {
                        name: "dragging"
                        when: topLeftHandleArea.pressed

                        PropertyChanges {
                            topLeftHandle {
                                color: Colors.theme.tertiary
                            }
                        }
                    }
                ]

                MouseArea {
                    id: topLeftHandleArea

                    cursorShape: Qt.SizeFDiagCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(topLeftHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(topLeftHandleArea, mouse.x, mouse.y);
                        const newW = Math.max(50, container.pressW - d.x);
                        const newH = Math.max(50, container.pressH - d.y);
                        content.component.width = newW;
                        content.component.height = newH;
                        container.x = container.pressX + container.pressW - newW;
                        container.y = container.pressY + container.pressH - newH;
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
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.right
                anchors.verticalCenter: parent.bottom

                states: [
                    State {
                        name: "hovered"
                        when: bottomRightHandleArea.containsMouse && !bottomRightHandleArea.pressed

                        PropertyChanges {
                            bottomRightHandle {
                                color: Colors.theme.secondary
                            }
                        }
                    },
                    State {
                        name: "dragging"
                        when: bottomRightHandleArea.pressed

                        PropertyChanges {
                            bottomRightHandle {
                                color: Colors.theme.tertiary
                            }
                        }
                    }
                ]

                MouseArea {
                    id: bottomRightHandleArea

                    cursorShape: Qt.SizeFDiagCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(bottomRightHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(bottomRightHandleArea, mouse.x, mouse.y);
                        content.component.width = Math.max(50, container.pressW + d.x);
                        content.component.height = Math.max(50, container.pressH + d.y);
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
                visible: container.focused
                width: container.handlerSize
                height: container.handlerSize
                radius: container.handlerSize
                color: Colors.theme.primary
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.bottom

                states: [
                    State {
                        name: "hovered"
                        when: bottomLeftHandleArea.containsMouse && !bottomLeftHandleArea.pressed

                        PropertyChanges {
                            bottomLeftHandle {
                                color: Colors.theme.secondary
                            }
                        }
                    },
                    State {
                        name: "dragging"
                        when: bottomLeftHandleArea.pressed

                        PropertyChanges {
                            bottomLeftHandle {
                                color: Colors.theme.tertiary
                            }
                        }
                    }
                ]

                MouseArea {
                    id: bottomLeftHandleArea

                    cursorShape: Qt.SizeBDiagCursor
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: container.focused
                    preventStealing: true
                    onPressed: mouse => container.grabPress(bottomLeftHandle, mouse.x, mouse.y)
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return;
                        const d = container.globalDelta(bottomLeftHandleArea, mouse.x, mouse.y);
                        const newW = Math.max(50, container.pressW - d.x);
                        const newH = Math.max(50, container.pressH + d.y);
                        content.component.width = newW;
                        content.component.height = newH;
                        container.x = container.pressX + container.pressW - newW;
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

            Component.onCompleted: {
                x = (parent.width - width) / 2;
                y = (parent.height - height) / 2;
            }
        }

        Component.onCompleted: {
            for (const s of Quickshell.screens) {
                contentWidth = Math.max(contentWidth, s.x + s.width);
                contentHeight = Math.max(contentHeight, s.y + s.height) / 2;
            }
        }
    }
}
