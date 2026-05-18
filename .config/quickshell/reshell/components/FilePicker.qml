import QtQuick
import Quickshell.Io

Process {
    id: process

    signal output(string path)

    function active() {
        process.running = true;
    }

    command: ["quickcli", "file-picker"]

    stdout: StdioCollector {
        onStreamFinished: {
            const path = this.text;
            if (path.length > 0)
                process.output(this.text.trim("%0A"));

        }
    }

}
