import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

Page {
    ColumnLayout {
        id: general
        property QtObject config: Global.getConfigManager(`${screen.name}-navbar`).adapter
        property bool side: config ? (config.position === "left" || config.position === "right") : false
        width: parent.width

        clip: true

        Toggle {
            text: "Enable Greeter"
            checked: Global.general.greeter
            onCheckedChanged: {
                Global.general.greeter = checked;
                Global.save();
            }
        }
    }
}
