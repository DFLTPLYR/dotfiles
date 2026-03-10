import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.core
import qs.components

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true

    // filepicker
    FilePicker {
        id: file
        onOutput: data => {
            if (data)
                overview.paths.push(data.trim("%0A"));
        }
    }

    Button {
        text: "Add File"
        onClicked: file.running = true
    }

    Flickable {
        id: flick
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        property real zoom: 1

        contentWidth: 2000 * zoom
        contentHeight: 2000 * zoom
        property int baseWidth: 2000
        property int baseHeight: 2000

        function zoomAt(point, factor) {
            var newZoom = Math.max(0.5, Math.min(zoom * factor, 5));
            resizeContent(baseWidth * newZoom, baseHeight * newZoom, point);
            zoom = newZoom;
            returnToBounds();
        }

        Item {
            id: overview
            anchors.centerIn: parent
            width: flick.baseWidth
            height: flick.baseHeight
            property list<var> paths: []

            Instantiator {
                model: Quickshell.screens
                delegate: Rectangle {
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
            }

            Instantiator {
                model: ScriptModel {
                    values: {
                        return [...overview.paths];
                    }
                }
                delegate: Rectangle {
                    id: container
                    parent: overview

                    required property var modelData
                    property Item image: draggableImage

                    Image {
                        id: draggableImage
                        property bool lock
                        width: sourceSize.width / flick.zoom
                        height: sourceSize.height / flick.zoom
                        source: Qt.resolvedUrl(modelData) || ""
                        Drag.active: imageMa.drag.active
                        Drag.hotSpot.x: 10
                        Drag.hotSpot.y: 10

                        MouseArea {
                            id: imageMa
                            anchors.fill: parent
                            drag.target: parent
                            hoverEnabled: true
                            // enabled: !draggableImage.lock
                            onPressed: flick.interactive = false

                            onReleased: flick.interactive = true

                            onCanceled: flick.interactive = true
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
