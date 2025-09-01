pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.animations

// yoinked at https://github.com/end-4/dots-hyprland/blob/main/.config/quickshell/ii/services/ResourceUsage.qml but extended

Singleton {
    id: root
    // memory
    property double memoryTotal: 1
    property double memoryFree: 1
    property double memoryUsed: memoryTotal - memoryFree
    property double memoryUsedPercentage: memoryUsed / memoryTotal

    // Swap
    property double swapTotal: 1
    property double swapFree: 1
    property double swapUsed: swapTotal - swapFree
    property double swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0

    function updateMemoryStats() {
        fileMeminfo.reload();
        const textMeminfo = fileMeminfo.text();
        memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)[1] ?? 1);
        memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)[1] ?? 0);
        swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)[1] ?? 1);
        swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)[1] ?? 0);
    }

    // Cpu
    property double cpuUsage: 0
    property var previousCpuStats

    function updateCpuStats() {
        fileStat.reload();
        const textStat = fileStat.text();
        const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
        if (!cpuLine)
            return;

        const stats = cpuLine.slice(1).map(Number);
        const total = stats.reduce((a, b) => a + b, 0);
        const idle = stats[3];

        if (previousCpuStats) {
            const totalDiff = total - previousCpuStats.total;
            const idleDiff = idle - previousCpuStats.idle;
            cpuUsage = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;
        }

        previousCpuStats = {
            total,
            idle
        };
    }

    // Network
    property string netInterface: ""
    property var prevNet: ({
            rx: 0,
            tx: 0,
            t: 0
        })

    property double netUploadValue: 0
    property double netDownloadValue: 0

    property string netUpload: humanRate(netUploadValue)
    property string netDownload: humanRate(netDownloadValue)

    function humanRate(bytesPerSec) {
        if (bytesPerSec >= 1024 * 1024)
            return (bytesPerSec / (1024 * 1024)).toFixed(2) + " MB/s";
        else if (bytesPerSec >= 1024)
            return (bytesPerSec / 1024).toFixed(1) + " KB/s";
        else
            return bytesPerSec.toFixed(0) + " B/s";
    }

    function detectInterface() {
        var lines = netStat.text().trim().split("\n");
        for (var i = 2; i < lines.length; i++) {
            var parts = lines[i].trim().split(":");
            if (parts.length < 2)
                continue;
            var iface = parts[0].trim();

            if (iface !== "lo" && !iface.startsWith("vir") && !iface.startsWith("docker")) {
                return iface;
            }
        }
        return "";
    }

    function updateNetworkStats() {
        netStat.reload();

        if (netInterface === "") {
            netInterface = detectInterface();
            if (netInterface === "") {
                console.warn("No active network interface found.");
                return;
            }
        }

        var now = Date.now();
        var lines = netStat.text().trim().split("\n");
        for (var i = 2; i < lines.length; i++) {
            var parts = lines[i].trim().split(":");
            if (parts.length < 2)
                continue;

            var iface = parts[0].trim();
            if (iface === netInterface) {
                var fields = parts[1].trim().split(/\s+/).map(Number);
                var rxBytes = fields[0];
                var txBytes = fields[8];

                if (prevNet.t > 0) {
                    var dt = (now - prevNet.t) / 1000.0;
                    var rxRate = (rxBytes - prevNet.rx) / dt;
                    var txRate = (txBytes - prevNet.tx) / dt;

                    netDownloadValue = rxRate;
                    netUploadValue = txRate;
                }

                prevNet.rx = rxBytes;
                prevNet.tx = txBytes;
                prevNet.t = now;
                break;
            }
        }
    }

    Timer {
        interval: 1
        running: true
        repeat: true
        onTriggered: {
            root.updateMemoryStats();
            root.updateCpuStats();
            root.updateNetworkStats();
            interval = 6000;
        }
    }

    FileView {
        id: fileMeminfo
        path: "/proc/meminfo"
    }

    FileView {
        id: fileStat
        path: "/proc/stat"
    }

    FileView {
        id: netStat
        path: "/proc/net/dev"
    }

    // animate
    Behavior on memoryTotal {
        AnimatedNumber {}
    }
    Behavior on memoryFree {
        AnimatedNumber {}
    }
    Behavior on memoryUsed {
        AnimatedNumber {}
    }
    Behavior on memoryUsedPercentage {
        AnimatedNumber {}
    }
    Behavior on swapTotal {
        AnimatedNumber {}
    }
    Behavior on swapFree {
        AnimatedNumber {}
    }
    Behavior on swapUsed {
        AnimatedNumber {}
    }
    Behavior on swapUsedPercentage {
        AnimatedNumber {}
    }
    Behavior on cpuUsage {
        AnimatedNumber {}
    }
    Behavior on netUploadValue {
        AnimatedNumber {}
    }
    Behavior on netDownloadValue {
        AnimatedNumber {}
    }
}
