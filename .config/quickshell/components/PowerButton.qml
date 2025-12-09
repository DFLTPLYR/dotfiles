import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import qs.config
import qs.assets

Item {
    id: root
    property bool isSlotted: false
    height: (Config.navbar.side && root.isSlotted) ? (parent ? parent.width : 0) : (parent ? parent.height : 0)
    width: (Config.navbar.side && root.isSlotted) ? (parent ? parent.width : 0) : (parent ? parent.height : 0)

    Button {
        id: actionBtn
        height: Config.navbar.side ? parent.height : parent.width
        width: Config.navbar.side ? height : parent.width
        text: "power_settings_new"
        font.family: FontProvider.fontMaterialOutlined
        onClicked: {
            Config.sessionMenuOpen = true;
        }
    }
}
