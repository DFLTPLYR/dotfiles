import QtQuick

import qs.core

Item {
    id: navbar
    default property alias content: container.data
    width: Navbar.config.side ? Navbar.config.width : parent.width
    height: !Navbar.config.side ? Navbar.config.height : parent.height

    Rectangle {
        id: container
        color: Navbar.config.style.color
        border {
            width: Navbar.config.style.border.width
            color: Navbar.config.style.border.color
        }
        anchors {
            fill: parent
            topMargin: Navbar.config.style.margin.top
            bottomMargin: Navbar.config.style.margin.bottom
            leftMargin: Navbar.config.style.margin.left
            rightMargin: Navbar.config.style.margin.right
        }
    }

    // Instantiate
    DropArea {
        anchors.fill: parent
        onContainsDragChanged: {
            container.border.color = containsDrag ? "red" : Qt.rgba(0, 0, 0, 0.3);
        }
    }
}
