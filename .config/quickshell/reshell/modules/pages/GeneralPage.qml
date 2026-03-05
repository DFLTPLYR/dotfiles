import QtQuick
import QtQuick.Layouts

import qs.components
import qs.core

ColumnLayout {
    required property var settings
    Layout.fillWidth: true
    Layout.fillHeight: true
    Slider {}
    Button {
        onClicked: {
            const positions = ["left", "top", "right", "bottom"];
            const currentIndex = positions.indexOf(settings.position);
            settings.position = positions[(currentIndex + 1) % positions.length];
        }
    }
}
