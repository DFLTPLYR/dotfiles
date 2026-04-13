import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.core
import qs.components

FloatingWindow {
    id: wallpaperModal

    title: "Reshell"

    color: "transparent"
    visible: Compositor.focusedWindow === screen.name && Global.edit

    minimumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)
    maximumSize: Qt.size(screen.width / 1.5, screen.height / 1.5)

    Loader {
        active: wallpaperModal.visible
        sourceComponent: Rectangle {
            id: container
            color: "transparent"

            width: screen.width / 1.5
            height: screen.height / 1.5

            border {
                width: 1
                color: Colors.color.primary
            }

            clip: true

            // Nav
            TopLeftControl {}

            Flickable {
                id: flick
                property var selection: undefined
                property real zoom: 1
                property int maxX: 0
                property int maxY: 0
                anchors.fill: parent

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
                            model: ScriptModel {
                                values: [...Wallpaper.config.layers]
                            }
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
                        var delta = event.angleDelta.y > 0 ? 0.1 : -0.1;
                        flick.zoom = Math.max(0.1, Math.min(5, flick.zoom + delta));
                    }
                }
            }

            function imageToScreenPosition() {
                var images = content.children.filter(s => s instanceof PreviewImage);
                var screens = content.children.filter(s => s instanceof Monitor);

                for (var i in images) {
                    const target = images[i];
                    var props = {
                        source: target.image.source,
                        width: target.width,
                        height: target.height,
                        x: target.x,
                        y: target.y,
                        z: target.z,
                        name: target.objectName,
                        screens: []
                    };
                    for (var j in screens) {
                        const screen = screens[j];
                        var sx = screen.x;
                        var sy = screen.y;
                        var sw = screen.width;
                        var sh = screen.height;
                        var imgRight = props.x + props.width;
                        var imgBottom = props.y + props.height;
                        var screenRight = sx + sw;
                        var screenBottom = sy + sh;
                        if (props.x < screenRight && imgRight > sx && props.y < screenBottom && imgBottom > sy) {
                            var relative = {
                                x: target.x - screen.x,
                                y: target.y - screen.y,
                                name: screen.objectName
                            };
                            props.screens.push(relative);
                        }
                    }

                    Wallpaper.config.layers = Wallpaper.config.layers.filter(s => s.name !== target.objectName);
                    Wallpaper.config.layers.push(props);
                }

                Wallpaper.save();
                Qt.callLater(() => {
                    panel.onSaveCustomWallpaper();
                });
            }

            Component.onCompleted: {
                Global.bindRadii(this);
                Global.wallpaper = true;
            }
            Component.onDestruction: Global.wallpaper = false
        }
    }

    component Monitor: Rectangle {
        id: monitor
        required property ShellScreen modelData
        property var dock: Global.getConfigManager(`${modelData.name}-dock`)
        width: modelData.width
        height: modelData.height
        color: Colors.setOpacity(Colors.color.background, 0.2)
        objectName: modelData.name
        border {
            width: 1 * flick.zoom
            color: Colors.color.primary
        }
        x: modelData.x
        y: modelData.y
    }

    component PreviewImage: ResizeableRect {
        id: container

        required property var modelData
        property Image image: draggableImage
        property var found
        pointerVisible: hoverHandler.hovered
        objectName: modelData.name

        width: (modelData.width || draggableImage.sourceSize.width)
        height: (modelData.height || draggableImage.sourceSize.height)

        x: (modelData.x || 0)
        y: (modelData.y || 0)

        // image
        Image {
            id: draggableImage
            property bool lock: (modelData.x && modelData.y) ? true : false
            width: container.width
            height: container.height
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
                        var layers = Wallpaper.config.layers;
                        var idx = layers.findIndex(s => s.name === container.modelData.name);
                        if (idx >= 0) {
                            var newLayers = [...layers];
                            newLayers.splice(idx, 1);
                            Wallpaper.config.layers = newLayers;
                        }
                    }
                }
            }

            DragHandler {
                id: dragHandler
                target: container
                enabled: !draggableImage.lock
            }

            HoverHandler {
                id: hoverHandler
                target: container
                enabled: !draggableImage.lock
                onHoveredChanged: container.z = hovered ? (container.z + 10) : (container.z - 10)
            }
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
                        panel.fileExplorerOpen = true;
                        fileExplorer.active();
                    }
                }

                Button {
                    text: "Check"
                    onClicked: container.imageToScreenPosition()
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
                    width: 150
                    Instantiator {
                        readonly property list<string> schemes: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"]
                        model: schemes
                        delegate: CheckBox {
                            text: modelData
                            checked: modelData === Wallpaper.config.theme
                            onClicked: {
                                Wallpaper.config.theme = modelData;
                                panel.onSaveCustomWallpaper();
                                Wallpaper.save();
                            }
                        }
                        onObjectAdded: (idx, obj) => {
                            colorScheme.insertItem(idx, obj);
                        }
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

    component ResizeableRect: Rectangle {
        id: resizeableRect
        property int rulersSize: 12 / flick.zoom
        required property bool pointerVisible

        border {
            width: 2
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
}
