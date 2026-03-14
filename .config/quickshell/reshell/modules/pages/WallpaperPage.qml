import QtQuick
import QtQuick.Layouts

import Quickshell
import QtCore
import qs.core
import qs.components

ColumnLayout {
    id: wallpaperpage
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true

    function imageToScreenPosition() {
        var images = content.children.filter(s => s instanceof PreviewImage);
        var screens = content.children.filter(s => s instanceof Monitor);

        for (var i in images) {
            const target = images[i].image;
            var props = {
                source: target.source,
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
    }

    // filepicker
    FilePicker {
        id: file
        onOutput: data => {
            if (data) {
                var image = {
                    source: data.trim("%0A"),
                    name: Math.random().toString(36).substring(2, 10)
                };
                Wallpaper.config.layers.push(image);
                Wallpaper.save();
            }
        }
    }

    Rectangle {
        color: "transparent"
        Layout.fillWidth: true
        Layout.fillHeight: true

        TopLeftControl {}

        border {
            width: 1
            color: Colors.color.primary
        }

        Flickable {
            id: flick

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
                        model: Wallpaper.config.layers
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
    }

    component TopLeftControl: Row {
        z: 2
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 5
            topMargin: 5
        }
        Button {
            text: "add file"
            onClicked: file.active()
        }

        Button {
            text: "check"
            onClicked: wallpaperpage.imageToScreenPosition()
        }

        Button {
            text: "save preset"
            onClicked: {
                var preset = {
                    source: Wallpaper.config.layers,
                    name: Math.random().toString(36).substring(2, 10)
                };
                Wallpaper.config.preset.push(preset);
                Wallpaper.config.layers = [];
            }
        }

        Button {
            text: "generate color"
            onClicked: Wallpaper.generatecolor()
        }
    }

    component Monitor: Rectangle {
        required property ShellScreen modelData
        width: modelData.width
        height: modelData.height
        color: Colors.color.background
        objectName: modelData.name
        border {
            width: 1 * flick.zoom
            color: Colors.color.primary
        }
        x: modelData.x
        y: modelData.y
    }

    component PreviewImage: Item {
        id: container

        required property var modelData
        property Image image: draggableImage
        property var found
        // image
        Image {
            id: draggableImage
            property bool lock: (modelData.x && modelData.y) ? true : false

            width: (modelData.width || sourceSize.width)
            height: (modelData.height || sourceSize.height)
            source: Qt.resolvedUrl(modelData.source) || ""
            x: (modelData.x || 0)
            y: (modelData.y || 0)
            Drag.active: drag.active
            Drag.hotSpot.x: 10
            Drag.hotSpot.y: 10
            objectName: modelData.name

            DragHandler {
                id: drag
                target: draggableImage
                enabled: !draggableImage.lock
            }
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
            }
        }

        // corner handler for resizing
        Repeater {
            model: [
                {
                    anchors: ["left", "top"]
                },
                {
                    anchors: ["right", "top"]
                },
                {
                    anchors: ["left", "bottom"]
                },
                {
                    anchors: ["right", "bottom"]
                },
            ]
            delegate: Rectangle {
                id: cornerHandle
                z: 2
                height: 20 / flick.zoom
                width: height
                radius: height / 2
                color: "green"
                opacity: !draggableImage.lock ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                anchors {
                    horizontalCenter: modelData.anchors.includes("left") ? draggableImage.left : modelData.anchors.includes("right") ? draggableImage.right : undefined
                    verticalCenter: modelData.anchors.includes("top") ? draggableImage.top : modelData.anchors.includes("bottom") ? draggableImage.bottom : undefined
                }

                MouseArea {
                    id: cornerPoint
                    anchors.fill: parent
                    drag.target: parent
                    enabled: !draggableImage.lock
                    onPositionChanged: mouse => {
                        if (drag.active) {
                            var anchors = modelData.anchors;
                            if (anchors.includes("right")) {
                                draggableImage.width = Math.max(50, parent.x - draggableImage.x);
                            }
                            if (anchors.includes("left")) {
                                var newWidth = draggableImage.width + (draggableImage.x - parent.x);
                                draggableImage.x = parent.x;
                                draggableImage.width = Math.max(50, newWidth);
                            }
                            if (anchors.includes("bottom")) {
                                draggableImage.height = Math.max(50, parent.y - draggableImage.y);
                            }
                            if (anchors.includes("top")) {
                                var newHeight = draggableImage.height + (draggableImage.y - parent.y);
                                draggableImage.y = parent.y;
                                draggableImage.height = Math.max(50, newHeight);
                            }
                        }
                    }
                }

                states: State {
                    when: cornerPoint.drag.active
                    AnchorChanges {
                        target: cornerHandle
                        anchors {
                            horizontalCenter: undefined
                            verticalCenter: undefined
                        }
                    }
                }
            }
        }
    }
}
