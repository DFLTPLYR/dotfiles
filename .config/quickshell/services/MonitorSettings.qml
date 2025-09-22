// MonitorSettings.qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var filePath: './monitor.json'
    property var temperature
    property var gamma

    FileView {
        id: monitorJson
        path: Qt.resolvedUrl(filePath)
        onLoaded: {
            commandProc.command = ["sh", "-c", "hyprctl hyprsunset gamma && hyprctl hyprsunset temperature"];
            commandProc.running = true;

            console.log("[Monitor] File loaded");
        }
        onLoadFailed: error => {
            if (error == FileViewError.FileNotFound) {
                console.log("[Monitor] File not found, creating new file.");
                commandProc.command = ["sh", "-c", "hyprctl hyprsunset gamma && hyprctl hyprsunset temperature"];
                commandProc.running = true;
            } else {
                console.log("[Monitor] Error loading file: " + error);
            }
        }
    }

    Process {
        id: commandProc
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim();
                const lines = out.split('\n');
                var monitorSettings = {
                    gamma: {
                        currentVal: lines[0],
                        min: 30,
                        max: 150
                    },
                    temperature: {
                        currentVal: lines[1],
                        min: 1000,
                        max: 20000
                    }
                };

                root.gamma = monitorSettings.gamma;
                root.temperature = monitorSettings.temperature;
                monitorJson.setText(JSON.stringify(monitorSettings));
            }
        }
    }
}
