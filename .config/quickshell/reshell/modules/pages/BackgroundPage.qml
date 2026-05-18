pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.core
import qs.components

Pane {
    id: page
    focus: true
    clip: true

    width: parent.width
    height: parent.height

    Component {
        id: contentImage
        Image {
            anchors.fill: parent
        }
    }

    // Nav
    TopLeftControl {}

    Flickable {
        id: flick
        property real zoom: 1
        property int maxX: 0
        property int maxY: 0

        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Control) {
                flick.interactive = false;
                selectionMa.enabled = true;
            }
        }
        Keys.onReleased: {
            flick.interactive = true;
            selectionMa.enabled = false;
        }

        contentWidth: maxX + 2000
        contentHeight: maxY + 2000

        transformOrigin: Item.Center

        // background grid
        Canvas {
            id: canvas
            clip: false
            width: flick.contentWidth
            height: flick.contentHeight
            onPaint: {
                var ctx = getContext("2d");
                var gridSize = 10;

                ctx.strokeStyle = Colors.setOpacity(Colors.color.tertiary, 0.5);
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

        // overview
        Item {
            id: overview
            width: flick.contentWidth
            height: flick.contentHeight

            Item {
                id: content

                scale: flick.zoom
                transformOrigin: Item.TopLeft
                anchors.centerIn: parent

                // selectionRect
                Rectangle {
                    id: selectionRect
                    x: 0
                    y: 0
                    z: 0
                    visible: false
                    onVisibleChanged: {
                        if (!visible && selectionRect.width !== 0 && selectionRect.height !== 0) {
                            const container = {
                                width: selectionRect.width,
                                height: selectionRect.height,
                                x: selectionRect.x,
                                y: selectionRect.y,
                                z: selectionRect.z,
                                screens: overlapsAny(selectionRect),
                                contents: {}
                            };
                            Wallpaper.containers.append(container);
                            Wallpaper.containers.save();
                        }
                    }

                    width: 0
                    height: 0
                    rotation: 0
                    color: Colors.setOpacity(Colors.color.primary, 0.5)
                    border.width: 1
                    border.color: Colors.color.tertiary
                    transformOrigin: Item.TopLeft
                }

                // screens/monitors
                Instantiator {
                    model: Quickshell.screens
                    delegate: Monitor {
                        parent: content
                    }
                    onObjectAdded: (idx, obj) => {
                        obj.parent = content;
                        var m = obj.modelData;
                        if (m.x + m.width > flick.maxX)
                            flick.maxX = m.x + m.width;
                        if (m.y + m.height > flick.maxY)
                            flick.maxY = m.y + m.height;
                    }
                }

                // containers
                Instantiator {
                    model: Wallpaper.containers
                    delegate: ContainerRect {
                        parent: content
                    }
                }
            }

            MouseArea {
                id: selectionMa
                anchors.fill: parent
                anchors.centerIn: parent
                enabled: false
                acceptedButtons: Qt.LeftButton
                property bool selecting
                property point startPoint

                onPressed: mouse => {
                    if (mouse.button == Qt.LeftButton) {
                        selecting = true;
                        startPoint = selectionMa.mapToItem(content, mouse.x, mouse.y);
                        selectionRect.x = startPoint.x;
                        selectionRect.y = startPoint.y;
                        selectionRect.width = 0;
                        selectionRect.height = 0;
                        selectionRect.visible = true;
                    }
                }

                onPositionChanged: mouse => {
                    if (selecting) {
                        const toLocal = selectionMa.mapToItem(content, mouse.x, mouse.y);
                        var minX = Math.min(startPoint.x, toLocal.x);
                        var minY = Math.min(startPoint.y, toLocal.y);
                        var maxX = Math.max(startPoint.x, toLocal.x);
                        var maxY = Math.max(startPoint.y, toLocal.y);

                        selectionRect.x = minX;
                        selectionRect.y = minY;
                        selectionRect.width = maxX - minX;
                        selectionRect.height = maxY - minY;
                    }
                }

                onReleased: {
                    selecting = false;
                    selectionRect.visible = false;
                }
            }
        }

        // zoom in/out
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            target: null

            onWheel: event => {
                let isShiftWheel = event.modifiers & Qt.ShiftModifier;
                if (isShiftWheel) {
                    let delta = event.angleDelta.y > 0 ? 0.1 : -0.1;
                    flick.zoom = Math.max(0.1, Math.min(5, flick.zoom + delta));
                }
            }
        }
    }

    function overlapsAny(target) {
        const screens = content.children.filter(s => s instanceof Monitor);
        const newScreens = [];
        for (let i = 0; i < screens.length; i++) {
            const screen = screens[i];

            if (intersects(target, screen)) {
                newScreens.push(getRelativePos(target, screen));
            }
        }
        return newScreens;
    }

    function intersects(a, b) {
        return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
    }

    function getRelativePos(target, screen) {
        var relative = {
            x: target.x - screen.x,
            y: target.y - screen.y,
            name: screen.objectName
        };
        return relative;
    }

    component Monitor: Rectangle {
        id: monitor
        required property ShellScreen modelData

        // border
        Outline {
            anchors.fill: parent
            zoom: flick.zoom
        }

        width: modelData.width
        height: modelData.height
        color: Colors.setOpacity(Colors.color.background, 0.5)
        objectName: modelData.name
        x: modelData.x
        y: modelData.y
        z: -10
    }

    component Outline: Item {
        id: outline
        property real zoom: 1
        focusPolicy: Qt.NoFocus
        focus: false
        // border
        Rectangle {
            anchors {
                top: parent.top
                right: parent.right
                left: parent.left
            }
            height: 2 / outline.zoom
            color: Colors.color.primary
        }

        Rectangle {
            anchors {
                bottom: parent.bottom
                right: parent.right
                left: parent.left
            }
            height: 2 / outline.zoom
            color: Colors.color.primary
            y: parent.height
        }

        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: 2 / outline.zoom
            color: Colors.color.primary
        }
        Rectangle {
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: 2 / outline.zoom
            color: Colors.color.primary
            x: parent.width
        }
    }

    component WidgetPlaceholder: Item {
        id: origPlacement
        required property var modelData
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        Layout.preferredHeight: 100

        Rectangle {
            id: container
            color: "transparent"

            width: origPlacement.width
            height: origPlacement.height
            border.color: Colors.color.primary
            Drag.active: ma.drag.active
            Drag.keys: [modelData.source]

            LazyLoader {
                active: container.visible
                source: modelData.source
                onItemChanged: {
                    if (item) {
                        item.parent = container;
                        item.width = container.width;
                        item.height = container.height;
                    }
                }
            }

            Drag.onActiveChanged: {
                if (Drag.active) {
                    container.parent = page;
                }
            }

            states: [
                State {
                    when: ma.drag.active
                    ParentChange {
                        target: container
                        parent: page
                    }
                },
                State {
                    when: !ma.drag.active
                    ParentChange {
                        target: container
                        parent: origPlacement
                    }
                }
            ]

            MouseArea {
                id: ma
                anchors.fill: parent
                drag.target: container
                onReleased: {
                    container.x = 0;
                    container.y = 0;
                    container.Drag.drop();
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    component ControlHandler: Item {
        id: control
        required property var subject
        property alias drag: dragHandler
        property alias hover: hoverHandler
        property alias wheel: wheelHandler
        signal update

        anchors.fill: parent
        z: -1000

        DragHandler {
            id: dragHandler
            target: control.subject
            onActiveChanged: control.update()
        }

        HoverHandler {
            id: hoverHandler
            target: subject
            onHoveredChanged: {
                control.focus = hovered ? true : false;
            }
        }

        WheelHandler {
            id: wheelHandler
            enabled: dragHandler.enabled
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            target: null

            onWheel: event => {
                let isShiftWheel = event.modifiers & Qt.ShiftModifier;
                if (isShiftWheel && wheelHandler.enabled) {
                    if (event.angleDelta.y > 0) {
                        subject.z++;
                    } else {
                        subject.z--;
                    }
                }
                control.update();
            }
        }
    }

    component ContainerRect: ResizeableRect {
        id: containerRect
        required property var model
        required property int index
        required property var contents

        property bool enabled: false
        property bool show: true
        property ListModel screens: ListModel {}
        onContentsChanged: {
            switch (contents.type) {
            case "image":
                const image = contentImage.createObject(containerRect, {
                    source: contents.source,
                    z: -1,
                    visible: Qt.binding(() => {
                        return !containerRect.hide;
                    })
                });
                image.visible = Qt.binding(() => {
                    return containerRect.show;
                });
                return;
            case "widget":
                const component = Qt.createComponent(contents.source);
                const incubator = component.incubateObject(containerRect, {});
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function (status) {
                        if (status === Component.Ready) {
                            const widget = incubator.object;
                            widget.parent = containerRect;
                            widget.anchors.fill = containerRect;
                            if (contents.props) {
                                widget.property.setProperty(contents.props);
                            }
                            widget.visible = Qt.binding(() => {
                                return containerRect.show;
                            });
                        }
                    };
                }
                return;
            }
        }

        bg.color: Colors.setOpacity(Colors.color.background, 0.5)

        pointerVisible: containerRect.enabled
        rulersSize: 16 / flick.zoom

        width: model.width
        height: model.height

        x: model.x
        y: model.y
        z: model.z

        Row {
            anchors {
                left: parent.left
                top: parent.top
                margins: 4
            }

            Button {
                width: 14 / flick.zoom
                height: 14 / flick.zoom

                Icon {
                    color: Colors.color.on_background
                    font.pixelSize: parent.width
                    text: containerRect.enabled ? "lock-slash" : "lock"
                }

                onClicked: containerRect.enabled = !containerRect.enabled
            }
            Button {
                width: 14 / flick.zoom
                height: 14 / flick.zoom

                Icon {
                    color: Colors.color.on_background
                    font.pixelSize: parent.width
                    text: containerRect.show ? "eye-slash" : "eye"
                }

                onClicked: {
                    containerRect.show = !containerRect.show;
                }
            }
        }

        Text {
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            text: `z: ${containerRect.z}`
            color: Colors.color.primary
            font.pixelSize: 12 / flick.zoom
        }

        ControlHandler {
            id: imageControl
            subject: containerRect
            drag.enabled: containerRect.enabled
            onUpdate: {
                const screens = overlapsAny(containerRect);

                const obj = {
                    x: containerRect.x,
                    y: containerRect.y,
                    z: containerRect.z,
                    screens: screens,
                    width: containerRect.width,
                    height: containerRect.height,
                    contents: containerRect.contents
                };

                Wallpaper.containers.set(containerRect.index, obj);
                updateTimer.restart();
            }
        }

        Timer {
            id: updateTimer
            interval: 5000
            onTriggered: Wallpaper.containers.save()
        }

        // outline
        Outline {
            anchors.fill: parent
            zoom: flick.zoom
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            enabled: menu.closed
            onClicked: menu.open()
        }

        Loader {
            active: widgetMenu.opened
            anchors.fill: parent
            sourceComponent: DropArea {
                objectName: "Slot"
                onDropped: drop => {
                    const widget = {
                        type: "widget",
                        source: drop.keys[0]
                    };

                    Wallpaper.containers.setProperty(containerRect.index, "contents", widget);
                    Wallpaper.containers.save();
                }
            }
        }

        Menu {
            id: menu
            width: 200
            x: containerRect.width

            FilePicker {
                id: imagePicker
                onOutput: data => {
                    Wallpaper.containers.setProperty(containerRect.index, "contents", {
                        type: "image",
                        source: data
                    });
                    contentImage.createObject(containerRect, {
                        source: data,
                        z: -1,
                        visible: Qt.binding(() => {
                            return containerRect.show;
                        })
                    });
                    Wallpaper.containers.save();
                }
            }

            Action {
                text: containerRect.contents?.type === "image" ? "Change Image" : "Add Image"
                onTriggered: {
                    imagePicker.active();
                }
            }

            Action {
                text: "Remove Container"
                onTriggered: {
                    Wallpaper.containers.remove(containerRect.index, 1);
                    Wallpaper.containers.save();
                }
            }

            Menu {
                id: widgetMenu
                title: "Widgets"
                height: 500
                width: 300

                ColumnLayout {
                    width: parent.width
                    Repeater {
                        model: ScriptModel {
                            values: [...Global.widgets]
                        }
                        delegate: WidgetPlaceholder {}
                    }
                }
            }
        }
    }

    component TopLeftControl: Row {
        id: controlContainer
        z: 2

        readonly property list<Monitor> screens: content.children.filter(s => s instanceof Monitor)
        readonly property list<ContainerRect> containers: content.children.filter(s => s instanceof ContainerRect)

        property bool showImages: true
        property bool showMonitors: true
        property bool showContainers: false

        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 5
            topMargin: 5
        }

        MenuBar {
            Menu {
                title: 'Layers'

                Action {
                    text: Global.docks ? "Hide Docks" : "Show Docks"
                    onTriggered: Global.docks = !Global.docks
                }

                Action {
                    text: "Save preset"
                    onTriggered: {
                        var preset = {
                            source: Wallpaper.config.layers,
                            name: Math.random().toString(36).substring(2, 10)
                        };
                        Wallpaper.config.preset.push(preset);
                        Wallpaper.config.layers = [];
                    }
                }

                Menu {
                    id: colorScheme
                    title: "Theme Picker"
                    width: 125

                    Instantiator {
                        model: Colors.themes
                        delegate: Action {
                            required property var modelData
                            checkable: true
                            checked: modelData === Wallpaper.config.theme
                            text: modelData.replace("scheme-", "")
                            onToggled: Wallpaper.config.theme = modelData
                        }
                        onObjectAdded: (obj, idx) => colorScheme.insertAction(obj, idx)
                    }
                }
            }

            Menu {
                id: screenMenu
                title: "Screens"
                Instantiator {
                    model: [...controlContainer.screens]
                    delegate: Action {
                        required property var modelData
                        text: modelData.objectName
                        checkable: true
                        checked: modelData.visible
                        onCheckedChanged: {
                            modelData.visible = this.checked;
                        }
                    }
                    onObjectAdded: (idx, obj) => screenMenu.insertAction(idx, obj)
                }
            }

            Menu {
                id: imageMenu
                title: "Containers"
                Instantiator {
                    model: [...controlContainer.containers]
                    delegate: Action {
                        required property var modelData
                        required property int index
                        text: index

                        checkable: true
                        checked: modelData.visible
                        onCheckedChanged: {
                            modelData.visible = this.checked;
                        }
                    }
                    onObjectAdded: (idx, obj) => imageMenu.insertAction(idx, obj)
                }
            }
        }
    }
}
