import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

ColumnLayout {
    required property var settings
    Layout.fillWidth: true
    Layout.fillHeight: true

    Slider {
        height: 40
        width: 2
    }

    RowLayout {
        Layout.fillWidth: true
        Label {
            text: "Anchor Positions"
        }
        Repeater {
            id: positions
            model: ["left", "top", "right", "bottom"]
            delegate: Button {
                required property string modelData
                text: modelData
                onClicked: {
                    settings.position = modelData;
                }
            }
        }
    }
}
