pragma ComponentBehavior: Bound
import QtQuick

import Quickshell

import qs.core
import qs.components

Pane {
    id: page

    width: parent.width
    height: parent.height

    FilePicker {
        id: filepicker
        onOutput: data => {
            const item = {
                name: Math.random().toString(36).substring(2, 10),
                source: data
            };
            Wallpaper.list.append(item);
        }
    }

    clip: true

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
                    z: 9999
                    visible: false
                    onVisibleChanged: {
                        if (!visible && selectionRect.width !== 0 && selectionRect.height !== 0) {
                            const container = {
                                width: selectionRect.width,
                                height: selectionRect.height,
                                x: selectionRect.x,
                                y: selectionRect.y,
                                z: selectionRect.z,
                                screens: overlapsAny(selectionRect)
                            };
                            Wallpaper.containers.append(container);
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

                // Images
                Instantiator {
                    model: Wallpaper.list
                    delegate: PreviewImage {
                        parent: content
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

    Component.onCompleted: {
        Global.bindRadii(this);
        Global.wallpaper = true;
    }

    Component.onDestruction: Global.wallpaper = false

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

    component PreviewImage: ResizeableRect {
        id: resizeableRect

        required property var modelData
        required property int index
        property ListModel screens: ListModel {}
        property Image image: draggableImage

        pointerVisible: imageControl.hover.hovered
        rulersSize: 12 / flick.zoom
        objectName: modelData.name

        width: (modelData.width || draggableImage.sourceSize.width)
        height: (modelData.height || draggableImage.sourceSize.height)

        x: (modelData.x || 0)
        y: (modelData.y || 0)
        z: (modelData.z || 0)

        // image
        Image {
            id: draggableImage
            property bool lock: (modelData.x && modelData.y) ? true : false
            width: resizeableRect.width
            height: resizeableRect.height
            source: Qt.resolvedUrl(modelData.source) || ""
            objectName: modelData.name
            z: -1

            // controls
            Row {
                z: 2
                opacity: 1

                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                Button {
                    width: 40 / flick.zoom
                    height: 40 / flick.zoom

                    Icon {
                        anchors.centerIn: parent
                        text: draggableImage.lock ? "lock" : "lock-slash"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }

                    onClicked: {
                        draggableImage.lock = !draggableImage.lock;
                    }
                }

                Button {
                    width: 40 / flick.zoom
                    height: 40 / flick.zoom
                    Icon {
                        anchors.centerIn: parent
                        text: "trash"
                        font.pixelSize: parent.width / 2
                        color: Colors.color.secondary
                    }
                    onClicked: {
                        Wallpaper.list.remove(resizeableRect.index, 1);
                        Wallpaper.list.save();
                    }
                }
            }
        }

        ControlHandler {
            id: imageControl
            subject: resizeableRect
            drag.enabled: !draggableImage.lock
            onUpdate: {
                const screens = overlapsAny(resizeableRect);

                const obj = {
                    x: resizeableRect.x,
                    y: resizeableRect.y,
                    z: resizeableRect.z,
                    screens: screens,
                    width: resizeableRect.width,
                    height: resizeableRect.height
                };

                Wallpaper.list.set(resizeableRect.index, obj);
            }
        }

        Text {
            anchors {
                left: parent.left
                top: parent.top
                margins: 4
            }
            text: `z: ${resizeableRect.z}`
            color: Colors.color.primary
            font.pixelSize: 12 / flick.zoom
        }

        // outline
        Outline {
            anchors.fill: parent
            zoom: flick.zoom
        }
    }

    component ControlHandler: Item {
        id: control
        required property var subject
        property alias drag: dragHandler
        property alias hover: hoverHandler
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
        property ListModel screens: ListModel {}

        color: Colors.setOpacity(Colors.color.background, 0.5)

        pointerVisible: true
        rulersSize: 16 / flick.zoom

        width: model.width
        height: model.height

        x: model.x
        y: model.y
        z: model.z

        Text {
            anchors {
                left: parent.left
                top: parent.top
                margins: 4
            }
            text: `z: ${containerRect.z}`
            color: Colors.color.primary
            font.pixelSize: 12 / flick.zoom
        }

        ControlHandler {
            id: imageControl
            subject: containerRect
            onUpdate: {
                const screens = overlapsAny(containerRect);

                const obj = {
                    x: containerRect.x,
                    y: containerRect.y,
                    z: containerRect.z,
                    screens: screens,
                    width: containerRect.width,
                    height: containerRect.height
                };

                Wallpaper.containers.set(containerRect.index, obj);
            }
        }

        // outline
        Outline {
            anchors.fill: parent
            zoom: flick.zoom
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                print("test");
            }
        }
    }

    component TopLeftControl: Row {
        id: controlContainer
        z: 2

        readonly property list<PreviewImage> imageList: content.children.filter(s => s instanceof PreviewImage)
        readonly property list<Monitor> screenList: content.children.filter(s => s instanceof Monitor)
        readonly property list<ContainerRect> containerList: content.children.filter(s => s instanceof ContainerRect)

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
                leftPadding: 2
                rightPadding: 2

                width: 150
                title: 'Layers'

                Button {
                    text: "Add file"
                    onClicked: {
                        filepicker.active();
                    }
                }

                Button {
                    text: "Check"
                    onClicked: {
                        for (const i in imageList) {
                            const target = imageList[i];
                            const screens = overlapsAny(imageList[i]);

                            const obj = {
                                x: target.x,
                                y: target.y,
                                z: target.z,
                                screens: screens,
                                width: target.width,
                                height: target.height
                            };

                            Wallpaper.list.set(target.index, obj);
                        }
                        Wallpaper.list.save();
                    }
                }

                Button {
                    text: Global.docks ? "Hide Docks" : "Show Docks"
                    onClicked: Global.docks = !Global.docks
                }

                Button {
                    text: "Save preset"
                    onClicked: {
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

                    DelegateModel {
                        id: themeDM
                        model: Colors.themes
                        delegate: CheckBox {
                            required property string modelData
                            width: ListView.view.width
                            text: modelData.replace("scheme-", "")
                            checked: modelData === Wallpaper.config.theme
                            onClicked: {
                                Wallpaper.config.theme = modelData;
                                Wallpaper.list.generate();
                            }
                        }
                    }

                    ListView {
                        width: parent.width
                        height: contentHeight
                        model: themeDM
                    }
                }
            }

            Menu {
                id: screenMenu
                title: "Screens"
                Instantiator {
                    model: [...controlContainer.screenList]
                    delegate: Action {
                        required property var modelData
                        text: modelData.objectName
                        checkable: true
                        checked: modelData.visible
                        onCheckedChanged: {
                            modelData.visible = this.checked;
                        }
                    }
                    onObjectAdded: (idx, obj) => {
                        screenMenu.insertAction(idx, obj);
                    }
                }
            }

            Menu {
                id: imageMenu
                title: "Images"
                Instantiator {
                    model: [...controlContainer.imageList]
                    delegate: Action {
                        required property var image
                        text: image.objectName

                        checkable: true
                        checked: image.visible
                        onCheckedChanged: {
                            image.visible = this.checked;
                        }
                    }
                    onObjectAdded: (idx, obj) => {
                        imageMenu.insertAction(idx, obj);
                    }
                }
            }
        }
    }
}
