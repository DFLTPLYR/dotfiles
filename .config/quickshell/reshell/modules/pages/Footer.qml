import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

RowLayout {
    id: footer
    property QtObject config
    Layout.fillWidth: true

    Label {
        text: ""
        Layout.fillWidth: true
    }

    Repeater {
        model: ["cancel", "save", "save and quit"]
        delegate: Button {
            text: modelData
            onClicked: {
                switch (modelData) {
                case "cancel":
                    footer.config.rollbackHistory();
                    break;
                case "save":
                    footer.config.save();
                    break;
                case "save and quit":
                    footer.config.save();
                    Qt.callLater(() => {
                        Global.enableSetting = false;
                    });
                    break;
                }
            }
        }
    }
}
