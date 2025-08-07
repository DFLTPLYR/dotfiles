import QtQuick
import Quickshell.Io

import qs.components

QtObject {
    id: button
    required property string command
    required property string text
    required property CustomIcon icon
    property var keybind: null

    readonly property var process: Process {
        command: ["sh", "-c", button.command]
    }

    function exec() {
        process.startDetached();
        Qt.quit();
    }
}
