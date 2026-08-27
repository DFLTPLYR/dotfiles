pragma ComponentBehavior: Bound

import QtCore
import QtQuick

import Quickshell
import Quickshell.Wayland
import qs.core
import qs.components

Item {
    id: panel
    property ShellScreen screen
    property var file
    property bool edit: false
    signal dockUpdate(var data)
    signal save
    focus: true

    // bottom
    PanelWindow {
        id: bottom
        property bool hasMenu: false
        screen: panel.screen

        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.keyboardFocus: bgMa.containsMouse || Global.edit ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        WlrLayershell.namespace: `Background-${screen.name}`
        WlrLayershell.layer: WlrLayer.Bottom

        mask: Region {
            item: controlArea
        }

        Item {
            id: layered
            anchors.fill: parent

            Repeater {
                id: bgRepeater
                model: ScriptModel {
                    values: Background.wallpaperArr
                }
                onItemAdded: (_idx, item) => {
                    item.parent = layered;
                }
                Component.onCompleted: {
                    delegate = Background.contentDelegate.createObject(null, {
                        panel: panel.screen
                    });
                }
            }
        }

        Item {
            id: controlArea
            property bool grab: false
            property bool select: false

            width: parent.width
            height: parent.height
            focus: true
            z: Global.normal ? 999 : 0

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Control) {
                    controlArea.grab = true;
                }
                if (event.key === Qt.Key_Shift) {
                    controlArea.select = true;
                }
            }

            Keys.onReleased: event => {
                if (event.key === Qt.Key_Control) {
                    controlArea.grab = false;
                }
                if (event.key === Qt.Key_Shift) {
                    controlArea.select = false;
                }
            }

            MouseArea {
                id: bgMa
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        contextMenu.x = mouse.x;
                        contextMenu.y = mouse.y;
                        contextMenu.open();
                    } else {
                        if (contextMenu.opened)
                            contextMenu.close();
                        if (controlArea.select) {
                            Background.selectionRect.selecting = true;
                            Background.selectionRect.startPoint = mapToGlobal(mouse.x, mouse.y);
                            Background.selectionRect.x = Background.selectionRect.startPoint.x;
                            Background.selectionRect.y = Background.selectionRect.startPoint.y;
                        }
                    }
                }

                onPositionChanged: mouse => {
                    const idx = Background.contextIdx;
                    if (idx < 0 || !controlArea.select)
                        return;
                    const sp = Background.selectionRect.startPoint;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    var minX = Math.min(sp.x, gp.x);
                    var minY = Math.min(sp.y, gp.y);
                    var maxX = Math.max(sp.x, gp.x);
                    var maxY = Math.max(sp.y, gp.y);
                    Background.selectionRect.x = minX;
                    Background.selectionRect.y = minY;
                    Background.selectionRect.width = maxX - minX;
                    Background.selectionRect.height = maxY - minY;
                }

                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    Background.selectionRect.selecting = false;
                }
            }

            // selectionRect
            Rectangle {
                id: selectionRect
                property bool intersect: Background.selectionRect.width > 0 && Background.selectionRect.height > 0 && Utils.intersects(Background.selectionRect, panel.screen)
                width: Math.min(Background.selectionRect.x + Background.selectionRect.width, panel.screen.x + panel.screen.width) - Math.max(Background.selectionRect.x, panel.screen.x)
                height: Math.min(Background.selectionRect.y + Background.selectionRect.height, panel.screen.y + panel.screen.height) - Math.max(Background.selectionRect.y, panel.screen.y)
                color: Colors.setOpacity(Colors.theme.on_primary, 0.5)
                opacity: Background.selectionRect.selecting && intersect ? 1 : 0

                border.width: 1
                border.color: Colors.theme.outline

                x: Math.max(Background.selectionRect.x, panel.screen.x) - panel.screen.x
                y: Math.max(Background.selectionRect.y, panel.screen.y) - panel.screen.y
                z: 9999

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Repeater {
                id: containerRepeater
                model: ScriptModel {
                    values: Background.widgetArr
                }
                delegate: Widget {}
            }
        }

        // simple desktop popup
        ContextMenu {
            id: contextMenu
            panel: panel
            area: controlArea
        }

        // Contents
        Connections {
            target: Background
            function onGenerate() {
                layered.grabToImage(function (result) {
                    result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);
                    if (!Global.readyBg.includes(panel.screen.name)) {
                        Global.readyBg = [...Global.readyBg, panel.screen.name];
                    }
                }, Qt.size(panel.screen.width, panel.screen.height));
            }
        }
    }

    component Widget: Rectangle {
        id: widget
        required property int index
        required property var modelData
        readonly property int handlerSize: 12
        property string path: modelData.path
        property alias ma: widgetMa
        property bool intersect: modelData.width > 0 && modelData.height > 0 && Utils.intersects(modelData, panel.screen)
        property var item

        property bool edit: false
        readonly property bool resizing: leftHandleArea.drag.active || rightHandleArea.drag.active || topHandleArea.drag.active || bottomHandleArea.drag.active || topRightHandleArea.drag.active || topLeftHandleArea.drag.active || bottomRightHandleArea.drag.active || bottomLeftHandleArea.drag.active
        property point pressPos
        property int pressX
        property int pressY
        property int pressW
        property int pressH

        onPathChanged: {
            incubateChild();
        }

        Component.onCompleted: {
            incubateChild();
        }

        function incubateChild() {
            const source = modelData?.path;
            if (!source)
                return;
            const component = Qt.createComponent(source);
            if (!component || component.status === Component.Error) {
                console.warn(`Failed to load widget ${source}: ${component?.errorString() ?? "invalid context"}`);
                return;
            }
            const incubator = component.incubateObject(widget, {});
            if (!incubator)
                return;
            const setup = comp => {
                if (widget.item) {
                    widget.item.destroy();
                }
                const props = Utils.getProperty(comp.property);
                widget.item = comp;

                if (!widget.modelData.property)
                    widget.modelData.setUp(props);

                comp.parent = widget;
                comp.anchors.fill = widget;
                comp.visible = Qt.binding(() => widget.intersect);
                widget.modelData.bindProperty(comp.property);
                comp.property.sharedContext = widget.modelData.property;
            };
            if (incubator.status === Component.Ready)
                setup(incubator.object);
            else
                incubator.onStatusChanged = status => {
                    if (status === Component.Ready)
                        setup(incubator.object);
                };
        }

        function grabPress(area, mx, my) {
            pressPos = area.mapToGlobal(mx, my);
            pressX = modelData.x;
            pressY = modelData.y;
            pressW = modelData.width;
            pressH = modelData.height;
        }

        width: modelData.width
        height: modelData.height
        color: "transparent"
        opacity: intersect ? 1 : 0
        x: modelData.x - panel.screen.x
        y: modelData.y - panel.screen.y
        z: modelData.z

        Outline {
            anchors.fill: parent
            opacity: widget.resizing || widget.edit || !modelData.path ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        MouseArea {
            id: widgetMa
            z: -1
            anchors.fill: parent
            hoverEnabled: widget.edit
            drag.target: widget.edit ? widget : null
            acceptedButtons: widget.edit ? Qt.RightButton | Qt.LeftButton : Qt.LeftButton
            propagateComposedEvents: true
            pressAndHoldInterval: 300
            onPositionChanged: mouse => {
                widget.modelData.x = panel.screen.x + parent.x;
                widget.modelData.y = panel.screen.y + parent.y;
            }
            onPressAndHold: mouse => {
                widget.edit = true;
            }
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    popup.x = mouse.x;
                    popup.y = mouse.y;
                    popup.opened ? popup.close() : popup.open();
                }
            }
            onExited: {
                if (!widget.resizing)
                    delayedExit.restart();
            }

            Timer {
                id: delayedExit
                interval: 300
                onTriggered: {
                    widget.edit = false;
                    Background.save();
                }
            }
        }

        Menu {
            id: popup
            width: 120

            Action {
                text: "Save"
                onTriggered: {
                    Background.save();
                }
            }

            Action {
                text: "Remove"
                onTriggered: {
                    const widgets = Background.widgetArr.slice();
                    widgets.splice(widget.index, 1);
                    Background.widgetArr = widgets;
                    Background.save();
                }
            }

            Menu {
                id: widgetMenu
                title: "widgets"

                Instantiator {
                    model: Global.widgets
                    delegate: Action {
                        required property var modelData
                        text: modelData.name
                        onTriggered: {
                            const source = modelData.source;
                            widget.modelData.path = source;
                            Background.save();
                        }
                    }
                    onObjectAdded: (idx, obj) => {
                        widgetMenu.insertAction(widgetMenu.count, obj);
                    }
                }
            }
        }

        // Sides
        Rectangle {
            id: leftHandle

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.verticalCenter
            opacity: widget.edit ? 1 : 0
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

                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    const newW = Math.max(30, widget.pressW - (gp.x - widget.pressPos.x));
                    widget.modelData.width = newW;
                    widget.modelData.x = widget.pressX + widget.pressW - newW;
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

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.verticalCenter
            opacity: widget.edit ? 1 : 0
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

                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    widget.modelData.width = Math.max(50, widget.pressW + (gp.x - widget.pressPos.x));
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

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            x: parent.x / 2
            y: 0
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.top
            opacity: widget.edit ? 1 : 0
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

                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    const newH = Math.max(50, widget.pressH - (gp.y - widget.pressPos.y));
                    widget.modelData.height = newH;
                    widget.modelData.y = widget.pressY + widget.pressH - newH;
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

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            x: parent.x / 2
            y: parent.y
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.bottom
            opacity: widget.edit ? 1 : 0
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
                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    widget.modelData.height = Math.max(50, widget.pressH + (gp.y - widget.pressPos.y));
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

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.top

            opacity: widget.edit ? 1 : 0
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

                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    const newW = Math.max(50, widget.pressW + (gp.x - widget.pressPos.x));
                    const newH = Math.max(50, widget.pressH - (gp.y - widget.pressPos.y));
                    widget.modelData.width = newW;
                    widget.modelData.height = newH;
                    widget.modelData.y = widget.pressY + widget.pressH - newH;
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

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.top

            opacity: widget.edit ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: topLeftHandleArea.containsMouse && !topLeftHandleArea.drag.active

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

                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    const newW = Math.max(50, widget.pressW - (gp.x - widget.pressPos.x));
                    const newH = Math.max(50, widget.pressH - (gp.y - widget.pressPos.y));
                    widget.modelData.width = newW;
                    widget.modelData.height = newH;
                    widget.modelData.x = widget.pressX + widget.pressW - newW;
                    widget.modelData.y = widget.pressY + widget.pressH - newH;
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

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.bottom

            opacity: widget.edit ? 1 : 0
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

                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    widget.modelData.width = Math.max(50, widget.pressW + (gp.x - widget.pressPos.x));
                    widget.modelData.height = Math.max(50, widget.pressH + (gp.y - widget.pressPos.y));
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

            width: widget.handlerSize
            height: widget.handlerSize
            radius: widget.handlerSize
            color: Colors.theme.primary
            anchors.horizontalCenter: parent.left
            anchors.verticalCenter: parent.bottom

            opacity: widget.edit ? 1 : 0
            states: [
                State {
                    name: "hovered"
                    when: bottomLeftHandleArea.containsMouse && !bottomLeftHandleArea.drag.active

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

                cursorShape: Qt.DragMoveCursor
                anchors.fill: parent
                enabled: widget.edit
                hoverEnabled: true
                onPressed: mouse => widget.grabPress(parent, mouse.x, mouse.y)
                onPositionChanged: mouse => {
                    if (!drag.active)
                        return;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    const newW = Math.max(50, widget.pressW - (gp.x - widget.pressPos.x));
                    const newH = Math.max(50, widget.pressH + (gp.y - widget.pressPos.y));
                    widget.modelData.width = newW;
                    widget.modelData.height = newH;
                    widget.modelData.x = widget.pressX + widget.pressW - newW;
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
    }
}
