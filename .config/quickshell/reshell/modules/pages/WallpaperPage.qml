import QtQuick
import QtQuick.Layouts

import Quickshell.Io
import qs.core
import qs.components

Item {
    Layout.fillWidth: true
    Layout.fillHeight: true

    FilePicker {
        anchors.fill: parent
        onOutput: data => {
            console.log(data);
        }
    }
}
