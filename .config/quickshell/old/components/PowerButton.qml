import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import qs.config
import qs.assets

Item {
    id: root
    property bool isSlotted: false
    height: (Navbar.config.side && root.isSlotted) ? (parent ? parent.width : 0) : (parent ? parent.height : 0)
    width: (Navbar.config.side && root.isSlotted) ? (parent ? parent.width : 0) : (parent ? parent.height : 0)

    Button {
        id: actionBtn
        height: Navbar.config.side ? parent.height : parent.width
        width: Navbar.config.side ? height : parent.width
        text: "power_settings_new"
        font.family: FontProvider.fontMaterialOutlined
        onClicked: {
            if (isSlotted)
                Config.sessionMenuOpen = true;
        }
    }
}
