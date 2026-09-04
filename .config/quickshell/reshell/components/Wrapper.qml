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
    property bool widget: false
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

    Component.onCompleted: {
        wrapper.menu = wrapper.property.menu;
    }
}
