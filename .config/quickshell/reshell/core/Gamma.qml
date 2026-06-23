pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: gamma

    property list<string> monitors: []
    readonly property string defaultPath: "/"

    function getPath(mon) {
        return mon ? `/outputs/${mon}` : defaultPath;
    }

    function detectMonitors() {
        detectProcess.running = true;
    }

    function setTemperature(temp, mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "set-property", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "Temperature", "q", String(temp)]
        });
    }

    function increaseTemperature(amount, mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "call", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "UpdateTemperature", "n", String(amount)]
        });
    }

    function decreaseTemperature(amount, mon) {
        gamma.increaseTemperature(-(amount ?? 100), mon);
    }

    function setInverted(inverted, mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "set-property", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "Inverted", "b", inverted ? "true" : "false"]
        });
    }

    function toggleInverted(mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "call", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "ToggleInverted"]
        });
    }

    function setBrightness(brightness, mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "set-property", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "Brightness", "d", String(brightness)]
        });
    }

    function increaseBrightness(amount, mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "call", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "UpdateBrightness", "d", String(amount)]
        });
    }

    function decreaseBrightness(amount, mon) {
        gamma.increaseBrightness(-(amount ?? 0.1), mon);
    }

    function setGamma(g, mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "set-property", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "Gamma", "d", String(g)]
        });
    }

    function increaseGamma(amount, mon) {
        Quickshell.execDetached({
            command: ["busctl", "--user", "call", "rs.wl-gammarelay", gamma.getPath(mon), "rs.wl.gammarelay", "UpdateGamma", "d", String(amount)]
        });
    }

    function decreaseGamma(amount, mon) {
        gamma.increaseGamma(-(amount ?? 0.1), mon);
    }

    Process {
        id: detectProcess
        command: ["busctl", "--user", "tree", "rs.wl-gammarelay"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const detected = [];
                for (const line of lines) {
                    const match = line.trim().match(/\/outputs\/(.+)$/);
                    if (match) {
                        detected.push(match[1]);
                    }
                }
                if (detected.length > 0) {
                    gamma.monitors = detected;
                }
            }
        }
    }

    Component.onCompleted: gamma.detectMonitors()
}
