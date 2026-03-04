import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Button {
        width: 40
        height: 40
        onClicked: {
            Global.general.button.hover.color = "red";
        }
    }
}
