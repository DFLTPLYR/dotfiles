pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQml.Models

import qs.core
import qs.components
import qs.modules.settings

Page {
    id: page
    Content {}

    Elements {}

    component Grid: Canvas {
        clip: false
        onPaint: {
            var ctx = getContext("2d");
            var gridSize = 10;

            ctx.strokeStyle = Colors.setOpacity(Colors.theme.on_surface, 0.5);
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

    component ResizeDot: Rectangle {
        id: dot
        signal press(var mouse)
        signal move(var mouse)
        signal release
        property int dotCursor: Qt.ArrowCursor
        property bool leftEdge: false
        property bool rightEdge: false
        property bool topEdge: false
        property bool bottomEdge: false
        width: 12
        height: 12
        radius: 12
        color: dotArea.containsMouse || dotArea.pressed ? Colors.theme.secondary : Colors.theme.primary

        MouseArea {
            id: dotArea
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            cursorShape: dot.dotCursor
            onPressed: mouse => dot.press(mouse)
            onPositionChanged: mouse => {
                if (!dotArea.pressed)
                    return;
                dot.move(mouse);
            }
            onReleased: dot.release()
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    component Content: GroupContainer {
        label: "Notification Section"

        Rectangle {
            color: "transparent"
            radius: 5
            height: page.height * 0.4

            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }

            border {
                width: 1
                color: Colors.theme.on_surface
            }

            Flickable {
                id: content
                property var focused

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

                    width: Components.polkit.width
                    height: Components.polkit.height
                    color: "transparent"

                    border {
                        width: 2
                        color: Colors.theme.primary
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton | Qt.LeftButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {} else {
                                content.focused = container;
                                Components.polkitSelectedItem = null;
                            }
                        }
                    }

                    Repeater {
                        model: Components.polkitElements
                    }

                    Item {
                        id: selectionOverlay
                        readonly property Item sel: Components.polkitSelectedItem
                        visible: sel !== null && sel.visible
                        x: (sel ? sel.x : 0) - dotRadius
                        y: (sel ? sel.y : 0) - dotRadius
                        width: (sel ? sel.width : 0) + dotRadius * 2
                        height: (sel ? sel.height : 0) + dotRadius * 2
                        z: 50

                        property int dotRadius: 6
                        property point pressPos
                        property real pressX
                        property real pressY
                        property real pressW
                        property real pressH

                        function grab(dot, mx, my) {
                            if (!sel)
                                return;
                            pressPos = dot.mapToGlobal(mx, my);
                            pressX = sel.x;
                            pressY = sel.y;
                            pressW = sel.width;
                            pressH = sel.height;
                        }

                        function resize(dot, mx, my) {
                            if (!sel)
                                return;
                            const gp = dot.mapToGlobal(mx, my);
                            const dx = gp.x - pressPos.x;
                            const dy = gp.y - pressPos.y;
                            if (dot.leftEdge) {
                                const w = Math.max(30, pressW - dx);
                                sel.width = w;
                                sel.x = pressX + pressW - w;
                            }
                            if (dot.rightEdge)
                                sel.width = Math.max(30, pressW + dx);
                            if (dot.topEdge) {
                                const h = Math.max(24, pressH - dy);
                                sel.height = h;
                                sel.y = pressY + pressH - h;
                            }
                            if (dot.bottomEdge)
                                sel.height = Math.max(24, pressH + dy);
                        }

                        function finish() {
                            if (sel)
                                Utils.clampToParent(sel);
                        }

                        ResizeDot {
                            id: leftDot
                            anchors.horizontalCenter: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            dotCursor: Qt.SizeHorCursor
                            leftEdge: true
                            onPress: mouse => selectionOverlay.grab(leftDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(leftDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                        ResizeDot {
                            id: rightDot
                            anchors.horizontalCenter: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            dotCursor: Qt.SizeHorCursor
                            rightEdge: true
                            onPress: mouse => selectionOverlay.grab(rightDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(rightDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                        ResizeDot {
                            id: topDot
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.top
                            dotCursor: Qt.SizeVerCursor
                            topEdge: true
                            onPress: mouse => selectionOverlay.grab(topDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(topDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                        ResizeDot {
                            id: bottomDot
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.bottom
                            dotCursor: Qt.SizeVerCursor
                            bottomEdge: true
                            onPress: mouse => selectionOverlay.grab(bottomDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(bottomDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                        ResizeDot {
                            id: topRightDot
                            anchors.horizontalCenter: parent.right
                            anchors.verticalCenter: parent.top
                            dotCursor: Qt.SizeBDiagCursor
                            rightEdge: true
                            topEdge: true
                            onPress: mouse => selectionOverlay.grab(topRightDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(topRightDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                        ResizeDot {
                            id: topLeftDot
                            anchors.horizontalCenter: parent.left
                            anchors.verticalCenter: parent.top
                            dotCursor: Qt.SizeFDiagCursor
                            leftEdge: true
                            topEdge: true
                            onPress: mouse => selectionOverlay.grab(topLeftDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(topLeftDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                        ResizeDot {
                            id: bottomRightDot
                            anchors.horizontalCenter: parent.right
                            anchors.verticalCenter: parent.bottom
                            dotCursor: Qt.SizeFDiagCursor
                            rightEdge: true
                            bottomEdge: true
                            onPress: mouse => selectionOverlay.grab(bottomRightDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(bottomRightDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                        ResizeDot {
                            id: bottomLeftDot
                            anchors.horizontalCenter: parent.left
                            anchors.verticalCenter: parent.bottom
                            dotCursor: Qt.SizeBDiagCursor
                            leftEdge: true
                            bottomEdge: true
                            onPress: mouse => selectionOverlay.grab(bottomLeftDot, mouse.x, mouse.y)
                            onMove: mouse => selectionOverlay.resize(bottomLeftDot, mouse.x, mouse.y)
                            onRelease: selectionOverlay.finish()
                        }
                    }

                    function grabPress(area, mx, my) {
                        pressPos = area.mapToGlobal(mx, my);
                        pressX = container.x;
                        pressY = container.y;
                        pressW = Components.polkit.width;
                        pressH = Components.polkit.height;
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
                                Components.polkit.width = newW;
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
                                Components.polkit.width = Math.max(50, container.pressW + d.x);
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
                                Components.polkit.height = newH;
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
                                Components.polkit.height = Math.max(50, container.pressH + d.y);
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
                                Components.polkit.width = newW;
                                Components.polkit.height = newH;
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
                                Components.polkit.width = newW;
                                Components.polkit.height = newH;
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
                                Components.polkit.width = Math.max(50, container.pressW + d.x);
                                Components.polkit.height = Math.max(50, container.pressH + d.y);
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
                                Components.polkit.width = newW;
                                Components.polkit.height = newH;
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
    }

    component Elements: GroupContainer {
        label: "Elements"

        Flickable {
            id: elementsFlick
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
            contentWidth: width
            contentHeight: elementsGrid.implicitHeight

            GridLayout {
                id: elementsGrid
                width: parent.width
                columns: 4

                Repeater {
                    model: Components.polkitElements.count
                    delegate: CheckBox {
                        required property int index
                        readonly property var target: Components.polkitElements.get(index)
                        text: target ? (target.label ?? ("Item " + index)) : ("Item " + index)
                        checked: target ? target.visible : true
                        onToggled: {
                            if (target)
                                target.visible = checked;
                        }
                    }
                }
            }
        }
    }
}
