import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

RowLayout {
    id: footer
    Layout.fillWidth: true
    signal cancel
    signal save(bool quit)
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
                    footer.cancel();
                    break;
                case "save":
                    footer.save(false);
                    break;
                case "save and quit":
                    footer.save(true);
                    break;
                }
            }
        }
    }
}
