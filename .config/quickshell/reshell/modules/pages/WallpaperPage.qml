pragma ComponentBehavior: Bound
import QtQuick

import Quickshell

import qs.core
import qs.components

Rectangle {
    id: container
    color: "transparent"

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

    border {
        width: 1
        color: Colors.color.primary
    }

    clip: true

    // Nav
    TopLeftControl {}

    Flickable {
        id: flick
        property real zoom: 1
        property int maxX: 0
        property int maxY: 0

        interactive: !selectionMa.selecting
        anchors.fill: parent

        focus: true
        Keys.onPressed: event => {
            print(event);
            switch (event.key) {
            case Qt.Key_Up:
                break;
            case Qt.Key_Down:
                break;
            case Qt.Key_Left:
                break;
            case Qt.Key_Right:
                break;
            default:
                break;
            }
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
            }
        }

        // zoom in/out
        WheelHandler {
            id: wheelHandler
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

        MouseArea {
            id: selectionMa
            enabled: false
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            property bool selecting
            property point startPoint

            onPressed: mouse => {
                if (mouse.button == Qt.LeftButton && mouse.modifiers & Qt.ControlModifier) {
                    selecting = true;
                    startPoint = Qt.point(mouse.x, mouse.y);
                    selectionRect.x = mouse.x;
                    selectionRect.y = mouse.y;
                    selectionRect.width = 0;
                    selectionRect.height = 0;
                    selectionRect.visible = true;
                }
            }

            onPositionChanged: mouse => {
                if (selecting) {
                    var minX = Math.min(startPoint.x, mouse.x);
                    var minY = Math.min(startPoint.y, mouse.y);
                    var maxX = Math.max(startPoint.x, mouse.x);
                    var maxY = Math.max(startPoint.y, mouse.y);

                    selectionRect.x = minX;
                    selectionRect.y = minY;
                    selectionRect.width = maxX - minX;
                    selectionRect.height = maxY - minY;
                }
            }

            onReleased: {
                selecting = false;
                selectionRect.visible = false;
                const container = {
                    w: selectionRect.width,
                    h: selectionRect.height,
                    x: selectionRect.x,
                    y: selectionRect.y,
                    z: selectionRect.z
                };
            }
        }

        // selectionRect
        Rectangle {
            id: selectionRect
            x: 0
            y: 0
            z: 9999
            visible: false
            width: 0
            height: 0
            rotation: 0
            color: Colors.setOpacity(Colors.color.primary, 0.5)
            border.width: 1
            border.color: Colors.color.tertiary
            transformOrigin: Item.TopLeft
        }
    }

    function overlapsAny(target) {
        const screens = content.children.filter(s => s instanceof Monitor);
        const newScreens = [];
        for (let i = 0; i < screens.length; i++) {
            const screen = screens[i];

            if (intersects(target, screen)) {
                newScreens.push(getRelativePos(target, screen));
                print(target, screen);
            }
        }

        let item = Wallpaper.list.get(target.index);
        item.x = target.x;
        item.y = target.y;
        item.z = target.z;
        item.screens = newScreens;
        item.width = target.width;
        item.height = target.height;
        Wallpaper.list.set(target.index, item);
        return false;
    }

    function find(model, criteria) {
        for (var i = 0; i < model.count; ++i)
            if (criteria(model.get(i)))
                return model.get(i);
        return null;
    }

    function findIndex(model, criteria) {
        for (var i = 0; i < model.count; ++i)
            if (criteria(model.get(i)))
                return i;
        return -1;
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
        // border
        Rectangle {
            width: parent.width
            height: 2 / outline.zoom
            color: Colors.color.primary
        }
        Rectangle {
            width: parent.width
            height: 2 / outline.zoom
            color: Colors.color.primary
            y: parent.height
        }

        Rectangle {
            width: 2 / outline.zoom
            height: parent.height
            color: Colors.color.primary
        }
        Rectangle {
            width: 2 / outline.zoom
            height: parent.height
            color: Colors.color.primary
            x: parent.width
        }
    }

    component PreviewImage: ResizeableRect {
        id: resizeableRect

        property Timer debounceTimer: Timer {
            interval: 100
            onTriggered: overlapsAny(resizeableRect)
        }

        required property var modelData
        required property int index
        property ListModel screens: ListModel {}
        onScreensChanged: print(screens)
        property Image image: draggableImage
        property var found

        pointerVisible: hoverHandler.hovered
        rulersSize: 12 / flick.zoom
        objectName: modelData.name

        width: (modelData.width || draggableImage.sourceSize.width)
        height: (modelData.height || draggableImage.sourceSize.height)

        x: (modelData.x || 0)
        y: (modelData.y || 0)
        z: (modelData.z || 0)

        onXChanged: debounceTimer.restart()
        onYChanged: debounceTimer.restart()

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

            DragHandler {
                id: dragHandler
                target: resizeableRect
                enabled: !draggableImage.lock
            }

            HoverHandler {
                id: hoverHandler
                target: resizeableRect
                enabled: !draggableImage.lock
            }

            WheelHandler {
                id: wheelHandler
                enabled: hoverHandler.hovered
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                target: null

                onWheel: event => {
                    let isShiftWheel = event.modifiers & Qt.ShiftModifier;
                    if (isShiftWheel && wheelHandler.enabled) {
                        if (event.angleDelta.y > 0) {
                            resizeableRect.z++;
                        } else {
                            resizeableRect.z--;
                        }
                    }
                }
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

    component TopLeftControl: Row {
        id: controlContainer
        z: 2
        readonly property list<PreviewImage> imageList: content.children.filter(s => s instanceof PreviewImage)
        readonly property list<Monitor> screenList: content.children.filter(s => s instanceof Monitor)

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
                            overlapsAny(imageList[i]);
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
                                Wallpaper.generatecolor();
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
                title: "Screens"
                Repeater {
                    model: [...controlContainer.screenList]
                    delegate: Button {
                        text: modelData.objectName
                    }
                }
            }

            Menu {
                title: "Images"
                Repeater {
                    model: [...controlContainer.imageList]
                    delegate: Button {
                        text: modelData.objectName
                    }
                }
            }
        }
    }
}
