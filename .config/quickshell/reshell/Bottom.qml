import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtCore

import qs.core
import qs.modules
import qs.components

PanelWindow {
    id: panel
    property var file
    property Item area: null
    property bool fileExplorerOpen: false

    signal dockUpdate(var data)

    color: "transparent"
    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: `Bottom-${screen.name}`
    WlrLayershell.layer: WlrLayer.Bottom

    mask: Region {
        item: panel.area
    }

    Item {
        id: controlContainer
        width: parent.width
        height: parent.height

        Instantiator {
            model: file.containers
            delegate: ResizeableRect {
                id: container
                property bool active: Global.edit
                required property var model
                required property int index
                pointerVisible: container.active
                parent: controlContainer
                width: model.w
                height: model.h

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }
                x: model.x
                y: model.y
                z: model.z
                color: container.active ? Colors.setOpacity(Colors.color.primary, 0.4) : "transparent"

                DragHandler {
                    id: dragHandler
                    target: parent
                }

                WheelHandler {
                    id: wheelHandler
                    enabled: container.active
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    target: null

                    onWheel: event => {
                        let isShiftWheel = event.modifiers & Qt.ShiftModifier;
                        if (isShiftWheel && wheelHandler.enabled) {
                            if (event.angleDelta.y > 0) {
                                parent.z++;
                            } else {
                                parent.z--;
                            }
                            print(parent.z);
                        }
                    }
                }

                MouseArea {
                    enabled: container.active
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if (!rectMenu.opened) {
                            rectMenu.x = mouseX + rectMenu.width > screen.width ? mouseX - rectMenu.width : mouseX;
                            rectMenu.y = mouseY + rectMenu.height > screen.height ? mouseY - rectMenu.height : mouseY;
                        }
                        rectMenu.opened ? rectMenu.close() : rectMenu.open();
                        return;
                    }
                }

                PopupModal {
                    id: rectMenu

                    width: content.width + (rectMenu.leftPadding + rectMenu.rightPadding)
                    height: content.height + (rectMenu.bottomPadding + rectMenu.topPadding)

                    ColumnLayout {
                        id: content
                        spacing: 0
                        width: 75
                        Button {
                            Layout.fillWidth: true
                            text: "save"
                            onClicked: {
                                const model = file.containers;
                                model.set(model.index, {
                                    "w": container.width,
                                    "h": container.height,
                                    "x": container.x,
                                    "y": container.y,
                                    "z": container.z
                                });
                                model.save();
                                print(model);
                            }
                        }
                        Button {
                            Layout.fillWidth: true
                            text: "remove"
                            onClicked: {
                                const model = file.containers;
                                model.remove(model.index, 1);
                                model.save();
                            }
                        }
                    }
                }
            }
        }
    }

    // MouseArea
    LazyLoader {
        active: Global.edit
        component: MouseArea {
            parent: controlContainer
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property bool selecting
            property point startPoint

            onPressed: mouse => {
                if (mouse.button == Qt.LeftButton && mouse.modifiers & Qt.ShiftModifier) {
                    selecting = true;
                    startPoint = Qt.point(mouse.x, mouse.y);
                    selectionRect.x = mouse.x;
                    selectionRect.y = mouse.y;
                    selectionRect.width = 0;
                    selectionRect.height = 0;
                    selectionRect.visible = true;
                } else if (mouse.button === Qt.RightButton) {
                    if (!contextMenu.opened) {
                        contextMenu.x = mouseX + contextMenu.width > screen.width ? mouseX - contextMenu.width : mouseX;
                        contextMenu.y = mouseY + contextMenu.height > screen.height ? mouseY - contextMenu.height : mouseY;
                    }
                    contextMenu.opened ? contextMenu.close() : contextMenu.open();
                    return;
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

            onReleased: mouse => {
                if (mouse.button == Qt.LeftButton && mouse.modifiers & Qt.ShiftModifier) {
                    selecting = false;
                    selectionRect.visible = false;

                    if (selectionRect.x == 0 && selectionRect.y == 0)
                        return;
                    const container = {
                        w: selectionRect.width,
                        h: selectionRect.height,
                        x: selectionRect.x,
                        y: selectionRect.y,
                        z: 1
                    };
                    file.containers.append(container);
                }
            }

            Component.onCompleted: {
                panel.area = this;
            }
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

    // simple desktop popup
    ContextMenu {
        id: contextMenu
    }
}
