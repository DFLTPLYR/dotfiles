pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.assets

// yoinked at https://github.com/end-4/dots-hyprland/blob/main/.config/quickshell/ii/services/ResourceUsage.qml but extended

Singleton {
    id: root
    // Raw data from API
    property var systemStats: ({})

    // Animated properties for CPU
    property double cpuUsage: systemStats.cpu ? systemStats.cpu.total / 100 : 0
    property int cpuCores: systemStats.cpu ? systemStats.cpu.cpucore : 0
    property int cpuCtxSwitches: systemStats.cpu ? systemStats.cpu.ctx_switches_rate_per_sec : 0

    // Animated properties for GPU
    property double gpuUsage: (systemStats.gpu && systemStats.gpu.length > 0) ? systemStats.gpu[0].proc / 100 : 0
    property double gpuTemp: (systemStats.gpu && systemStats.gpu.length > 0) ? (systemStats.gpu[0].temperature) : 0
    property double gpuMem: (systemStats.gpu && systemStats.gpu.length > 0) ? systemStats.gpu[0].mem / 100 : 0

    // Animated properties for Memory
    property double memUsage: systemStats.mem ? systemStats.mem.percent / 100 : 0
    property double memUsed: systemStats.mem ? systemStats.mem.used : 0
    property double memTotal: systemStats.mem ? systemStats.mem.total : 1
    property double memCached: systemStats.mem ? systemStats.mem.cached : 0
    property double memActive: systemStats.mem ? systemStats.mem.active : 0

    // Animated properties for Swap
    property double swapUsage: systemStats.memswap ? systemStats.memswap.percent / 100 : 0
    property double swapUsed: systemStats.memswap ? systemStats.memswap.used : 0
    property double swapTotal: systemStats.memswap ? systemStats.memswap.total : 1
    property double swapIn: systemStats.memswap ? systemStats.memswap.sin : 0
    property double swapOut: systemStats.memswap ? systemStats.memswap.sout : 0

    function getGlancesStats(callback) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:61208/api/4/all", true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var data = JSON.parse(xhr.responseText);
                var filtered = {
                    cpu: data.cpu,
                    gpu: data.gpu,
                    mem: data.mem,
                    memswap: data.memswap
                };
                root.systemStats = filtered; // Update the raw data

                // Update the animated properties
                cpuUsage = systemStats.cpu ? systemStats.cpu.total / 100 : 0;
                cpuCores = systemStats.cpu ? systemStats.cpu.cpucore : 0;
                cpuCtxSwitches = systemStats.cpu ? systemStats.cpu.ctx_switches_rate_per_sec : 0;

                gpuUsage = (systemStats.gpu && systemStats.gpu.length > 0) ? systemStats.gpu[0].proc / 100 : 0;
                gpuTemp = (systemStats.gpu && systemStats.gpu.length > 0) ? systemStats.gpu[0].temperature : 0;
                gpuMem = (systemStats.gpu && systemStats.gpu.length > 0) ? systemStats.gpu[0].mem / 100 : 0;

                memUsage = systemStats.mem ? systemStats.mem.percent / 100 : 0;
                memUsed = systemStats.mem ? systemStats.mem.used : 0;
                memTotal = systemStats.mem ? systemStats.mem.total : 1;
                memCached = systemStats.mem ? systemStats.mem.cached : 0;
                memActive = systemStats.mem ? systemStats.mem.active : 0;

                swapUsage = systemStats.memswap ? systemStats.memswap.percent / 100 : 0;
                swapUsed = systemStats.memswap ? systemStats.memswap.used : 0;
                swapTotal = systemStats.memswap ? systemStats.memswap.total : 1;
                swapIn = systemStats.memswap ? systemStats.memswap.sin : 0;
                swapOut = systemStats.memswap ? systemStats.memswap.sout : 0;

                if (callback)
                    callback(filtered);
            }
        };
        xhr.send();
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.getGlancesStats();
        }
    }

    Behavior on cpuUsage {
        AnimationProvider.NumberAnim {}
    }
    Behavior on cpuCores {
        AnimationProvider.NumberAnim {}
    }
    Behavior on cpuCtxSwitches {
        AnimationProvider.NumberAnim {}
    }

    Behavior on gpuUsage {
        AnimationProvider.NumberAnim {}
    }
    Behavior on gpuTemp {
        AnimationProvider.NumberAnim {}
    }
    Behavior on gpuMem {
        AnimationProvider.NumberAnim {}
    }

    Behavior on memUsage {
        AnimationProvider.NumberAnim {}
    }
    Behavior on memUsed {
        AnimationProvider.NumberAnim {}
    }
    Behavior on memTotal {
        AnimationProvider.NumberAnim {}
    }
    Behavior on memCached {
        AnimationProvider.NumberAnim {}
    }
    Behavior on memActive {
        AnimationProvider.NumberAnim {}
    }

    Behavior on swapUsage {
        AnimationProvider.NumberAnim {}
    }
    Behavior on swapUsed {
        AnimationProvider.NumberAnim {}
    }
    Behavior on swapTotal {
        AnimationProvider.NumberAnim {}
    }
    Behavior on swapIn {
        AnimationProvider.NumberAnim {}
    }
    Behavior on swapOut {
        AnimationProvider.NumberAnim {}
    }
}
