import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.core
import qs.components

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    // filepicker
    FilePicker {
        id: file
        onOutput: data => {
            if (data)
                overview.paths.push(data.trim("%0A"));
        }
    }

    Rectangle {
        color: "transparent"
        border {
            width: 1
            color: Colors.color.primary
        }
        Layout.fillWidth: true
        Layout.fillHeight: true

        Column {
            z: 10
            anchors {
                top: parent.top
                left: parent.left
                margins: 2
            }

            Row {
                Button {
                    text: flick.showGrid ? "hide grid" : "show grid"
                    onClicked: {
                        canvas.visible = !canvas.visible;
                    }
                }
                Repeater {
                    model: overview.children.filter(s => s instanceof Screens)
                    delegate: Button {
                        text: modelData.modelData.name
                        onClicked: {
                            var screenCenterX = overview.x + modelData.x + modelData.width / 2;
                            var screenCenterY = overview.y + modelData.y + modelData.height / 2;
                            flick.contentX = screenCenterX - flick.width / 2;
                            flick.contentY = screenCenterY - flick.height / 2;
                        }
                    }
                }
            }
            Button {
                text: "Add File"
                onClicked: file.running = true
            }

            Button {
                text: "Check pos"
                onClicked: {
                    var images = overview.children.filter(s => s instanceof CustomImage);
                    var screens = overview.children.filter(s => s instanceof Screens);

                    for (var i = 0; i < images.length; i++) {
                        var container = images[i];
                        var image = container.image;
                        var imgX = image.x;
                        var imgY = image.y;
                        var imgW = image.width;
                        var imgH = image.height;
                        var overlapping = [];
                        var properties = {
                            x: imgX,
                            y: imgY,
                            width: imgW * flick.zoom,
                            height: imgH * flick.zoom,
                            screens: []
                        };

                        for (var j = 0; j < screens.length; j++) {
                            var screen = screens[j];
                            if (screen.width > 0 && screen.height > 0) {
                                if (imgX < screen.x + screen.width && imgX + imgW > screen.x && imgY < screen.y + screen.height && imgY + imgH > screen.y) {
                                    overlapping.push(screen);
                                }
                            }
                        }
                        var panel = [];
                        for (var k = 0; k < overlapping.length; k++) {
                            var screen = overlapping[k];
                            var screenData = {
                                relativeX: screen.x - image.x,
                                relativeY: screen.y - image.y,
                                screenName: screen.modelData.name
                            };
                            panel.push(screenData);
                        }
                        properties.screens = panel;
                        console.log(JSON.stringify(properties));
                    }
                }
            }
        }
        ColumnLayout {
            anchors {
                right: parent.right
                margins: 2
            }
            layoutDirection: Qt.RightToLeft
            Text {
                text: `${flick.contentX.toFixed(0)} ${flick.contentY.toFixed(0)}`
                color: Colors.color.primary
            }
            Repeater {
                model: ["zoom in", "zoom out"]
                delegate: Button {
                    Layout.preferredWidth: 40
                    height: 40
                    Icon {
                        text: modelData === "zoom in" ? "search-plus" : "search-minus"
                        font.pixelSize: Math.min(parent.width, parent.height)
                        color: Colors.color.primary
                    }
                }
            }
        }

        Flickable {
            id: flick
            clip: true
            anchors.fill: parent
            property real zoom: 2

            contentWidth: 2000 * zoom
            contentHeight: 2000 * zoom
            property int baseWidth: 2000
            property int baseHeight: 2000
            property int gridSize: 100

            function zoomAt(point, factor) {
                var newZoom = Math.max(0.5, Math.min(zoom * factor, 5));
                resizeContent(baseWidth * newZoom, baseHeight * newZoom, point);
                zoom = newZoom;
                returnToBounds();
            }

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

            Item {
                id: overview
                anchors.centerIn: parent
                width: flick.baseWidth
                height: flick.baseHeight

                property list<var> paths: []

                Instantiator {
                    id: screenInstantiator
                    model: Quickshell.screens
                    delegate: Screens {
                        id: screenItem
                    }
                }

                Instantiator {
                    id: imageInstantiator
                    model: ScriptModel {
                        values: {
                            return [...overview.paths];
                        }
                    }
                    delegate: CustomImage {
                        parent: overview
                    }
                }
            }

            WheelHandler {
                id: wheelHandler
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                target: null

                onWheel: event => {
                    var point = Qt.point(event.x, event.y);
                    var factor = event.angleDelta.y > 0 ? 1.1 : 0.9;
                    flick.zoomAt(point, factor);
                    event.accepted = true;
                }
            }
        }
    }

    component Screens: Rectangle {
        id: screenRect
        required property ShellScreen modelData
        objectName: "screen"
        border {
            width: 1
            color: Colors.color.primary
        }
        color: Colors.setOpacity(Colors.color.background, 0.3)
        width: modelData.width / flick.zoom
        height: modelData.height / flick.zoom
        parent: overview
        x: modelData.x / flick.zoom
        y: modelData.y / flick.zoom
    }

    component CustomImage: Rectangle {
        id: container

        required property var modelData
        property Image image: draggableImage

        Image {
            id: draggableImage
            property bool lock

            width: (modelData.width || sourceSize.width) / flick.zoom
            height: (modelData.height || sourceSize.height) / flick.zoom

            source: Qt.resolvedUrl(modelData) || ""
            Drag.active: drag.active
            Drag.hotSpot.x: 10
            Drag.hotSpot.y: 10

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
                height: 10
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
