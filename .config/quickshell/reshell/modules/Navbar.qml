import QtQuick

import qs.core

Rectangle {
    id: navbar

    color: Navbar.config.style.color

    border {
        width: Navbar.config.style.border.width
        color: Navbar.config.style.border.color
    }

    width: Navbar.config.side ? Navbar.config.width : parent.width
    height: !Navbar.config.side ? Navbar.config.height : parent.height

    // Instantiate
    // DropArea {
    //     anchors.fill: parent
    //     onContainsDragChanged: {
    //         parent.border.color = containsDrag ? "red" : Qt.rgba(0, 0, 0, 0.3);
    //     }
    // }
}
