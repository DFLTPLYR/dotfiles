pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.animations

// yoinked at https://github.com/end-4/dots-hyprland/blob/main/.config/quickshell/ii/services/ResourceUsage.qml

Singleton {

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

    //Cpu
    property double cpuUsage: 0
    property var previousCpuStats

    Timer {
        interval: 1
        running: true
        repeat: true
        onTriggered: {
            // Reload files
            fileMeminfo.reload();
            fileStat.reload();

            // Parse memory and swap usage
            const textMeminfo = fileMeminfo.text();
            memoryTotal = Number(textMeminfo.match(/MemTotal: *(\d+)/)[1] ?? 1);
            memoryFree = Number(textMeminfo.match(/MemAvailable: *(\d+)/)[1] ?? 0);
            swapTotal = Number(textMeminfo.match(/SwapTotal: *(\d+)/)[1] ?? 1);
            swapFree = Number(textMeminfo.match(/SwapFree: *(\d+)/)[1] ?? 0);

            // Parse CPU usage
            const textStat = fileStat.text();
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (cpuLine) {
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

            interval = 3000;
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
}
