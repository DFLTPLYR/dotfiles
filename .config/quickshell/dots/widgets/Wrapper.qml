import QtQuick

import Quickshell
import qs.config

Item {
    default property alias content: widgetHandler.data
    property bool isSlotted: false

    property real contentWidth: {
        let sum = 0;
        for (let i = 0; i < widgetHandler.children.length; i++) {
            sum += widgetHandler.children[i].width;
        }
        return sum;
    }

    property real contentHeight: {
        let sum = 0;
        for (let i = 0; i < widgetHandler.children.length; i++) {
            sum += widgetHandler.children[i].height;
        }
        return sum;
    }

    width: {
        if (Navbar.config.side) {
            return parent.width;
        } else {
            return isSlotted ? contentWidth : parent.width;
        }
    }

    height: {
        if (Navbar.config.side) {
            return isSlotted ? contentHeight : parent.height;
        } else {
            return parent.height;
        }
    }

    Item {
        id: widgetHandler
        width: parent.width
        height: parent.height

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
    }
}
