pragma ComponentBehavior: Bound
import Quickshell

import QtQuick

import qs.core
import qs.types

Item {
    id: wrapper
    property var container
    property var slotConfig
    property var screen: Quickshell.screens[0]
    property Property property: Property {}
    property bool swapping: false
    property Menu menu

    signal drop(int mouseX, int mouseY)
    signal swap(int item1, int item2)
    signal remove
    signal modal(var modal, bool hasChanges)

    onMenuChanged: {
        menu.entered.connect(() => {
            return wrapper.modal(wrapper.menu, false);
        });

        menu.exited.connect(hasChanges => {
            return wrapper.modal(null, hasChanges);
        });
        menu.remove.connect(() => {
            wrapper.remove();
        });
    }

    function setSize() {
        if (wrapper.container && wrapper.slotConfig) {
            return wrapper.slotConfig.side ? wrapper.container.width : wrapper.container.height;
        }
        return 0;
    }

    function setWidth(data) {
        if (wrapper.slotConfig) {
            return wrapper.slotConfig.side ? wrapper.container.width : data;
        } else if (wrapper.container) {
            return wrapper.container.width;
        }
        return 0;
    }

    function setHeight(data) {
        if (wrapper.slotConfig) {
            return !wrapper.slotConfig.side ? wrapper.container.height : data;
        } else if (wrapper.container) {
            return wrapper.container.height;
        }
        return 0;
    }

    Drag.hotSpot: Qt.point(width / 2, height / 2)
    Drag.active: ma.drag.active

    MouseArea {
        id: ma
        enabled: Global.widget
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        preventStealing: true
        drag.target: wrapper
        drag.axis: wrapper.slotConfig ? (wrapper.slotConfig.side ? Drag.YAxis : Drag.XAxis) : Drag.XAndYAxis
        onReleased: mouse => {
            if (mouse.button === Qt.LeftButton) {
                wrapper.Drag.drop();
                wrapper.drop(mouseX, mouseY);
                parent.x = 0;
                parent.y = 0;
            } else {
                wrapper.menu.open();
            }
        }
    }

    DropArea {
        z: 1
        enabled: Global.widget
        anchors.fill: parent
        // stupid ass
        onEntered: drag => {
            const widgetA = drag.source.parent.DelegateModel.itemsIndex;
            const widgetB = wrapper.parent.DelegateModel.itemsIndex;
            wrapper.swap(widgetB, widgetA);
        }
        onContainsDragChanged: {
            background.border.width = containsDrag ? 1 : 0;
            background.border.color = containsDrag ? Colors.theme.tertiary : "transparent";
        }
    }

    Component.onCompleted: {
        wrapper.menu = wrapper.property.menu;
    }
}
