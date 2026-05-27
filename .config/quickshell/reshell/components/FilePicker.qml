import QtQuick
import Quickshell.Io

Process {
    id: process

    signal output(var file)

    function active() {
        process.running = true;
    }

    command: ["quickcli", "file-picker"]

    stdout: StdioCollector {
        onStreamFinished: {
            const path = this.text.trim("%0A");
            if (path.length > 0) {
                const file = {
                    url: path,
                    type: process.fileType(path)
                };
                process.output(file);
            }
        }
    }

    function fileType(path) {
        var types = {
            static: ["png", "jpg", "jpeg", "bmp", "svg", "ico", "webp"],
            animated: ["gif", "apng"]
        };
        if (!path)
            return "";
        var ext = String(path).toLowerCase().replace(/^.*\./, "");
        for (var t in types) {
            if (types[t].indexOf(ext) !== -1)
                return t;
        }
        return "";
    }
}
