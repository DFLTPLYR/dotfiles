pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.types
import qs.components
import qs.modules.settings
import System

Page {
    id: page

    GroupContainer {
        label: "Displays"

        Rectangle {
            id: exampleNotif
            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }
            height: 500
            width: parent.width
            color: Colors.theme.surface
            border {
                width: 1
                color: Colors.theme.on_surface
            }
            radius: 5
            clip: true

            Flickable {
                id: flick
                property real zoom: 0.1
                property int maxX: 0
                property int maxY: 0

                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                acceptedButtons: Qt.MiddleButton | Qt.LeftButton
                clip: true
                contentWidth: maxX + 2000
                contentHeight: maxY + 2000

                contentX: (contentWidth - width) / 2
                contentY: (contentHeight - height) / 2
                transformOrigin: Item.Center

                // background grid
                Canvas {
                    id: canvas
                    clip: false
                    // anchors.fill: parent
                    width: flick.contentWidth
                    height: flick.contentHeight
                    onPaint: {
                        var ctx = getContext("2d");
                        var gridSize = 10;

                        ctx.strokeStyle = Colors.setOpacity(Colors.theme.on_surface, 0.5);
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

                // Display
                Item {
                    id: content

                    scale: flick.zoom
                    transformOrigin: Item.Center
                    anchors.centerIn: parent

                    Repeater {
                        id: displayRepeater
                        model: Quickshell.screens
                        delegate: Rectangle {
                            id: display
                            required property ShellScreen modelData

                            width: modelData.width
                            height: modelData.height
                            color: Colors.setOpacity(Colors.theme.surface, 0.2)
                            x: modelData.x
                            y: modelData.y

                            // Outline
                            Item {
                                anchors.fill: parent
                                property real zoom: flick.zoom
                                focusPolicy: Qt.NoFocus
                                focus: false
                                // border
                                Rectangle {
                                    anchors {
                                        top: parent.top
                                        right: parent.right
                                        left: parent.left
                                    }
                                    height: 2 / flick.zoom
                                    color: Colors.theme.primary
                                }

                                Rectangle {
                                    anchors {
                                        bottom: parent.bottom
                                        right: parent.right
                                        left: parent.left
                                    }
                                    height: 2 / flick.zoom
                                    color: Colors.theme.primary
                                    y: parent.height
                                }

                                Rectangle {
                                    anchors {
                                        top: parent.top
                                        bottom: parent.bottom
                                        left: parent.left
                                    }
                                    width: 2 / flick.zoom
                                    color: Colors.theme.primary
                                }
                                Rectangle {
                                    anchors {
                                        top: parent.top
                                        bottom: parent.bottom
                                        right: parent.right
                                    }
                                    width: 2 / flick.zoom
                                    color: Colors.theme.primary
                                    x: parent.width
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onPressed: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        contextMenu.x = mouse.x;
                                        contextMenu.y = mouse.y;
                                        contextMenu.open();
                                    } else {
                                        if (contextMenu.opened)
                                            contextMenu.close();
                                    }
                                }
                            }

                            Menu {
                                id: contextMenu

                                Button {
                                    text: "change Image"
                                }
                            }
                        }
                    }
                }

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

                Component.onCompleted: {
                    for (const s of Quickshell.screens) {
                        maxX = Math.max(maxX, s.x + s.width);
                        maxY = Math.max(maxY, s.y + s.height);
                    }
                }
            }
        }

        Button {
            text: "Add Image"
            onClicked: {
                fm.open();
                print("clicked");
            }

            FileManager {
                id: fm
                onOutput: (path, mimeType) => console.log(path, mimeType)
            }
        }
    }
}
