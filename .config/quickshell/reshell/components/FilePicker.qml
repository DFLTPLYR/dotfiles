import QtQuick

import Quickshell.Io

Item {
    id: process
    signal output(string path)

    Process {
        id: filepicker
        command: ["pcli", "file-picker"]
        stdout: StdioCollector {
            onStreamFinished: {
                const path = this.text;
                if (path.length > 0) {
                    process.output(this.text, false);
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !filepicker.running
        onClicked: {
            filepicker.running = true;
        }
    }
}
