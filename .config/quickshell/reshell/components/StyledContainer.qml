import QtQuick
import QtQuick.Layouts

import qs.core

ResizeableRect {
    id: container
    signal save(int idx, var obj)
    signal remove(int idx)

    property bool active: Global.edit
    required property var model
    required property int index

    pointerVisible: container.active

    color: container.active ? Colors.setOpacity(Colors.color.primary, 0.4) : "transparent"
    width: model.w
    height: model.h
    x: model.x
    y: model.y
    z: model.z

    Behavior on color {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

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
                    const obj = {
                        "w": container.width,
                        "h": container.height,
                        "x": container.x,
                        "y": container.y,
                        "z": container.z
                    };
                    container.save(model.index, obj);
                }
            }

            Button {
                Layout.fillWidth: true
                text: "remove"
                onClicked: {
                    container.remove(model.index);
                }
            }
        }
    }
}
