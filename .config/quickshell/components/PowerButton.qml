import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import qs.config
import qs.assets

Item {
    property bool isSlotted: false
    height: Config.navbar.side ? parent.width : parent.height
    width: Config.navbar.side ? parent.width : parent.height

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
