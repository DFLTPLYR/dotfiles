import QtQuick

import Quickshell.Io

Process {
    id: process
    signal output(string path)
    command: ["pcli", "file-picker"]
    stdout: StdioCollector {
        onStreamFinished: {
            const path = this.text;
            if (path.length > 0) {
                process.output(this.text);
            }
        }
    }
    function active() {
        process.running = true;
    }
}
