pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components
import qs.modules.settings

Page {
    id: page

    GroupContainer {
        label: "Notification Section"

        Rectangle {
            id: exampleNotif
            color: Colors.theme.on_surface
            radius: 5
            height: page.height * 0.6

            anchors {
                left: parent.left
                leftMargin: parent.padding
                right: parent.right
                rightMargin: parent.padding
            }

            Content {}
        }
    }
    component Grid: Canvas {
        clip: false
        onPaint: {
            var ctx = getContext("2d");
            var gridSize = 10;

            ctx.strokeStyle = Colors.setOpacity(Colors.theme.on_primary, 0.5);
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

    component Content: Flickable {
        id: content
        property QtObject component: QtObject {
            property int width: 300
            property int height: 200
        }

        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        focus: true
        acceptedButtons: Qt.MiddleButton | Qt.LeftButton
        clip: true

        contentX: (contentWidth - width) / 2
        contentY: (contentHeight - height) / 2
        transformOrigin: Item.Center

        Grid {
            anchors.fill: parent
        }

        Rectangle {
            id: container
            width: content.component.width
            height: content.component.height
            color: "transparent"

            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            border {
                width: 2
                color: Colors.theme.outline
            }

            ResizeHandle {
                anchors.horizontalCenter: parent.left
                anchors.verticalCenter: parent.bottom
                onResize: (dx, dy) => {
                    const gp = mapToGlobal(dx, dy);
                    const newW = Math.max(30, (gp.x - container.x));
                    container.width = newW;
                }
            }
        }

        Pane {
            id: pane
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            height: 120
            width: 300

            ColumnLayout {
                anchors.fill: parent

                // Message Context

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Text {
                        text: "Message"
                        wrapMode: Text.Wrap
                        verticalAlignment: Text.AlignVCenter
                        color: Colors.theme.on_surface
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                    }
                }

                // Text Input
                TextField {
                    id: textInput
                    focus: true
                    echoMode: TextInput.Password
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Buttons
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight

                    // cancel
                    Button {
                        text: "Cancel"
                    }

                    // submit
                    Button {
                        text: "Submit"
                    }
                }
            }
        }

        Component.onCompleted: {
            for (const s of Quickshell.screens) {
                contentWidth = Math.max(contentWidth, s.x + s.width);
                contentHeight = Math.max(contentHeight, s.y + s.height) / 2;
            }
        }
    }

    component ResizeHandle: Rectangle {
        id: resizeHandle
        property int size: 18
        signal resize(int x, int y)
        width: size
        height: size
        radius: size / 2
        color: Colors.theme.primary

        states: [
            State {
                name: "hovered"
                when: resizeHandleArea.containsMouse && !resizeHandleArea.drag.active

                PropertyChanges {
                    resizeHandle {
                        color: Colors.theme.secondary
                    }
                }
            },
            State {
                name: "dragging"
                when: resizeHandleArea.drag.active

                PropertyChanges {
                    resizeHandle {
                        color: Colors.theme.tertiary
                    }
                }
            }
        ]

        MouseArea {
            id: resizeHandleArea

            cursorShape: Qt.DragMoveCursor
            anchors.fill: parent
            hoverEnabled: true
            onPressed: mouse => {}
            onMouseYChanged: {
                if (drag.active) {
                    resizeHandle.resize(mouseX, mouseY);
                }
            }
            onMouseXChanged: {
                if (drag.active) {
                    resizeHandle.resize(mouseX, mouseY);
                }
            }

            drag {
                target: parent
                axis: Drag.YAxis | Drag.XAxis
            }
        }
    }
}
