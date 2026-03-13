import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.core
import qs.components

ColumnLayout {
    id: wallpaperpage
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true

    // filepicker
    FilePicker {
        id: file
        onOutput: data => {
            if (data) {
                var image = {
                    source: data.trim("%0A"),
                    name: Math.random().toString(36).substring(2, 10)
                };
                Wallpaper.config.source.push(image);
                Wallpaper.save();
            }
        }
    }

    Rectangle {
        color: "transparent"
        Layout.fillWidth: true
        Layout.fillHeight: true

        border {
            width: 1
            color: Colors.color.primary
        }

        Row {
            z: 2
            anchors {
                top: parent.top
                left: parent.left
            }
            Button {
                text: "add file"
                onClicked: file.active()
            }
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
                    var gridSize = flick.gridSize;

                    ctx.strokeStyle = Qt.rgba(0.3, 0.3, 0.3, 1);
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
                id: content
                width: flick.contentWidth
                height: flick.contentHeight
                scale: flick.zoom
                transformOrigin: Item.TopLeft

                // screens/monitors
                Instantiator {
                    model: Quickshell.screens
                    delegate: Screen {
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
                    model: Wallpaper.config.source
                    delegate: PreviewImage {
                        parent: content
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

    component Screen: Rectangle {
        required property ShellScreen modelData
        width: modelData.width
        height: modelData.height
        color: Colors.color.background
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

        // image
        Image {
            id: draggableImage
            property bool lock
            width: (modelData.width || sourceSize.width)
            height: (modelData.height || sourceSize.height)
            source: Qt.resolvedUrl(modelData.source) || ""
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
                    width: 40
                    height: 40
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
                z: 10
                height: 50 * flick.zoom
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
