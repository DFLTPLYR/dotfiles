import QtQuick
import QtQuick.Layouts

import qs.core
import qs.components

Pane {
    ColumnLayout {
        width: parent.width
        height: contentHeight

        Label {
            text: "Greeter"
            font.pixelSize: 32
            Layout.fillWidth: true
        }

        Toggle {
            property bool greeter: Global.general.greeter
            text: greeter ? "Disable" : "Enable"
            checked: greeter
            onCheckedChanged: {
                Global.general.greeter = checked;
                Global.save();
            }
        }
    }
}
