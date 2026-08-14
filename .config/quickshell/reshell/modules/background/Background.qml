pragma ComponentBehavior: Bound

import QtQml.Models
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

    component LazyContainer: LazyLoader {
        id: containerloader
        required property int index
        required property var model
        property var relative: model.screens
        property var coords
        property var contents: model.contents
        property var currentContent
        onItemChanged: {
            if (!contents || !item)
                return;
            return addContent();
        }

        function addContent() {
            const type = contents.type;
            if (containerloader.currentContent) {
                containerloader.currentContent.destroy();
            }
            switch (type) {
            case "image":
                item.parent = layered;
                const img = Components.createImage(contents.source, contents.kind, item);
                containerloader.currentContent = img;
                return;
            case "widget":
                item.parent = controlArea;
                const component = Qt.createComponent(contents.source);
                const incubator = component.incubateObject(containerloader.item, {});
                if (incubator && incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function (status) {
                        if (status === Component.Ready) {
                            const widget = incubator.object;
                            widget.parent = containerloader.item;
                            widget.anchors.fill = containerloader.item;
                            containerloader.currentContent = widget;
                            if (contents.props) {
                                widget.property.setProperty(contents.props);
                            }
                            widget.modal.connect((modal, hasChanges) => {
                                bottom.hasMenu = modal ? true : false;
                                if (modal) {
                                    modal.y = item.height;
                                    modal.x = (item.width - modal.width) / 2;
                                }
                                if (hasChanges) {
                                    const props = widget.property.getProperty();
                                    const conf = Background.containers.get(containerloader.index);
                                    const withProps = conf.contents;
                                    withProps.props = props;
                                    Background.containers.setProperty(containerloader.index, "contents", withProps);
                                    Background.containers.save();
                                }
                            });
                        }
                    };
                }
                return;
            default:
                return;
            }
        }

        active: coords || false
        onRelativeChanged: {
            if (!relative || !relative.count)
                return;
            for (let i = 0; i < relative.count; i++) {
                const screen = relative.get(i);
                if (screen.name === panel.screen.name) {
                    return coords = screen;
                }
            }
        }

        component: Pane {
            bg.color: "transparent"
            bg.border.color: Global.widget ? Colors.theme.primary : "transparent"
            bg.border.width: Global.widget ? 2 : 0
            width: containerloader.model.width
            height: containerloader.model.height
            visible: containerloader.coords ? true : false
            x: containerloader.coords ? containerloader.coords.x : 0
            y: containerloader.coords ? containerloader.coords.y : 0
            z: containerloader.model.z
        }
    }

    Instantiator {
        model: DelegateModel {
            model: Background.containers
            delegate: LazyContainer {}
        }
    }

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

        WlrLayershell.keyboardFocus: bottom.hasMenu ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        WlrLayershell.namespace: `Background-${screen.name}`
        WlrLayershell.layer: WlrLayer.Bottom

        mask: Region {
            item: controlArea
        }

        Item {
            id: layered
            anchors.fill: parent
        }

        Item {
            id: controlArea
            width: parent.width
            height: parent.height

            MouseArea {
                z: -999999
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        contextMenu.x = mouse.x;
                        contextMenu.y = mouse.y;
                        contextMenu.open();
                    } else {
                        if (contextMenu.opened) {
                            contextMenu.close();
                        }
                        Background.contextArea.selecting = true;
                        Background.contextArea.startPoint = mapToGlobal(mouse.x, mouse.y);
                        Background.contextArea.x = Background.contextArea.startPoint.x;
                        Background.contextArea.y = Background.contextArea.startPoint.y;
                    }
                }

                onPositionChanged: mouse => {
                    const idx = Background.contextIdx;
                    if (idx < 0)
                        return;
                    const sp = Background.contextArea.startPoint;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    var minX = Math.min(sp.x, gp.x);
                    var minY = Math.min(sp.y, gp.y);
                    var maxX = Math.max(sp.x, gp.x);
                    var maxY = Math.max(sp.y, gp.y);
                    Background.contextArea.x = minX;
                    Background.contextArea.y = minY;
                    Background.contextArea.width = maxX - minX;
                    Background.contextArea.height = maxY - minY;
                }

                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    Background.contextArea.selecting = false;
                }
            }
        }

        // selectionRect
        Rectangle {
            id: selectionRect
            property bool intersect: Background.contextArea.width > 0 && Background.contextArea.height > 0 && intersects(Background.contextArea, panel.screen)
            width: Math.min(Background.contextArea.x + Background.contextArea.width, panel.screen.x + panel.screen.width) - Math.max(Background.contextArea.x, panel.screen.x)
            height: Math.min(Background.contextArea.y + Background.contextArea.height, panel.screen.y + panel.screen.height) - Math.max(Background.contextArea.y, panel.screen.y)
            color: Colors.setOpacity(Colors.theme.on_primary, 0.5)
            opacity: Background.contextArea.selecting && intersect ? 1 : 0

            border.width: 1
            border.color: Colors.theme.outline

            x: Math.max(Background.contextArea.x, panel.screen.x) - panel.screen.x
            y: Math.max(Background.contextArea.y, panel.screen.y) - panel.screen.y
            z: 9999

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // simple desktop popup
        ContextMenu {
            id: contextMenu
            screen: panel.screen
            x: (screen.width - width) / 2
            y: (screen.height - height) / 2
        }

        Repeater {
            model: ScriptModel {
                values: Background.boxes
            }
            delegate: Rectangle {
                id: box

                signal resized
                required property var modelData
                readonly property int handlerSize: 12
                readonly property bool pointerVisible: Global.widget
                property bool intersect: modelData.width > 0 && modelData.height > 0 && intersects(modelData, panel.screen)

                width: modelData.width
                height: modelData.height
                color: Colors.setOpacity(Colors.theme.on_primary, 0.5)
                opacity: intersect ? 1 : 0
                x: modelData.x - panel.screen.x
                y: modelData.y - panel.screen.y
                z: 9999

                Rectangle {
                    id: leftHandle

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressX
                        property int pressW

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressX = box.modelData.x;
                            pressW = box.modelData.width;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            const newW = Math.max(30, pressW - (gp.x - pressPos.x));
                            box.modelData.width = newW;
                            box.modelData.x = pressX + pressW - newW;
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

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressW

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressW = box.modelData.width;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            box.modelData.width = Math.max(50, pressW + (gp.x - pressPos.x));
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

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    x: parent.x / 2
                    y: 0
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.top
                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressY
                        property int pressH

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressY = box.modelData.y;
                            pressH = box.modelData.height;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            const newH = Math.max(50, pressH - (gp.y - pressPos.y));
                            box.modelData.height = newH;
                            box.modelData.y = pressY + pressH - newH;
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

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    x: parent.x / 2
                    y: parent.y
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.bottom
                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressH

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressH = box.modelData.height;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            box.modelData.height = Math.max(50, pressH + (gp.y - pressPos.y));
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

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.right
                    anchors.verticalCenter: parent.top

                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressX
                        property int pressY
                        property int pressW
                        property int pressH

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressX = box.modelData.x;
                            pressY = box.modelData.y;
                            pressW = box.modelData.width;
                            pressH = box.modelData.height;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            const newW = Math.max(50, pressW + (gp.x - pressPos.x));
                            const newH = Math.max(50, pressH - (gp.y - pressPos.y));
                            box.modelData.width = newW;
                            box.modelData.height = newH;
                            box.modelData.y = pressY + pressH - newH;
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

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.left
                    anchors.verticalCenter: parent.top

                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressX
                        property int pressY
                        property int pressW
                        property int pressH

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressX = box.modelData.x;
                            pressY = box.modelData.y;
                            pressW = box.modelData.width;
                            pressH = box.modelData.height;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            const newW = Math.max(50, pressW - (gp.x - pressPos.x));
                            const newH = Math.max(50, pressH - (gp.y - pressPos.y));
                            box.modelData.width = newW;
                            box.modelData.height = newH;
                            box.modelData.x = pressX + pressW - newW;
                            box.modelData.y = pressY + pressH - newH;
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

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.right
                    anchors.verticalCenter: parent.bottom

                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressX
                        property int pressY
                        property int pressW
                        property int pressH

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressX = box.modelData.x;
                            pressY = box.modelData.y;
                            pressW = box.modelData.width;
                            pressH = box.modelData.height;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            const newW = Math.max(50, pressW + (gp.x - pressPos.x));
                            const newH = Math.max(50, pressH + (gp.y - pressPos.y));
                            box.modelData.width = newW;
                            box.modelData.height = newH;
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

                    width: box.handlerSize
                    height: box.handlerSize
                    radius: box.handlerSize
                    color: Colors.theme.primary
                    anchors.horizontalCenter: parent.left
                    anchors.verticalCenter: parent.bottom

                    opacity: box.pointerVisible ? 1 : 0
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

                        property point pressPos
                        property int pressX
                        property int pressY
                        property int pressW
                        property int pressH

                        anchors.fill: parent
                        enabled: box.pointerVisible
                        hoverEnabled: true
                        onPressed: mouse => {
                            pressPos = mapToGlobal(mouse.x, mouse.y);
                            pressX = box.modelData.x;
                            pressY = box.modelData.y;
                            pressW = box.modelData.width;
                            pressH = box.modelData.height;
                        }
                        onPositionChanged: mouse => {
                            if (!drag.active)
                                return;
                            const gp = mapToGlobal(mouse.x, mouse.y);
                            const newW = Math.max(50, pressW - (gp.x - pressPos.x));
                            const newH = Math.max(50, pressH + (gp.y - pressPos.y));
                            box.modelData.width = newW;
                            box.modelData.height = newH;
                            box.modelData.x = pressX + pressW - newW;
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

                Behavior on opacity {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }

                MouseArea {
                    id: boxMa
                    anchors.fill: parent
                    z: -1
                    hoverEnabled: true
                    drag.target: box
                    onPositionChanged: mouse => {
                        box.modelData.x = panel.screen.x + parent.x;
                        box.modelData.y = panel.screen.y + parent.y;
                    }
                }
            }
        }

        // Contents
        Connections {
            target: Background.containers
            function onGenerate() {
                const screen = layered.grabToImage(function (result) {
                    result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);

                    const exist = Global.readyBg.find(panel.screen.name);
                    Global.readyBg = [...Global.readyBg, panel.screen.name];
                }, Qt.size(background.screen.width, background.screen.height));
            }
        }
    }

    function intersects(a, b) {
        return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
    }
}
