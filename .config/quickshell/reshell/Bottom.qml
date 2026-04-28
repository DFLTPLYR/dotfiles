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
    WlrLayershell.layer: Global.edit ? WlrLayer.Bottom : WlrLayer.Background

    mask: Region {
        item: panel.area
    }

    Item {
        id: controlContainer
        width: parent.width
        height: parent.height

        Instantiator {
            model: file.containers
            delegate: StyledContainer {
                parent: controlContainer
                onSave: (idx, obj) => {
                    const container = file.containers;
                    container.set(idx, obj);
                    container.save();
                }
                onRemove: idx => {
                    const container = file.containers;
                    container.remove(idx);
                    container.save();
                }
            }
        }
    }

    // MouseArea
    MouseArea {
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
