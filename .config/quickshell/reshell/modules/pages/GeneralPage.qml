import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

ColumnLayout {
    id: general
    property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
    property bool side: config ? (config.position === "left" || config.position === "right") : false
    Layout.fillWidth: true
    Layout.fillHeight: true

    Toggle {
        text: "Enable Greeter"
        checked: Global.general.greeter
        onCheckedChanged: {
            Global.general.greeter = checked;
            Global.save();
        }
    }
}
