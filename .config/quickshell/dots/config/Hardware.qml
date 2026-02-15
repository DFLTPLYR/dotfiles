pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string path: `${Quickshell.env("XDG_RUNTIME_DIR")}/pdaemon.sock`

    property bool ready: false
    property string lastError: ""
    property string os
    property string kernelVersion
    property string osVersion
    property int uptime
    property int bootTime

    // CPU
    property var cpu: ({
            architecture: "",
            usage: 0.0,
            frequency: 0,
            physicalCores: 0,
            cores: 0
        })

    // Memory
    property var memory: ({
            total: 0,
            used: 0,
            free: 0,
            totalSwap: 0,
            usedSwap: 0
        })

    // GPU
    property var gpu: ({
            vendor: "",
            model: "",
            family: "",
            deviceId: "",
            totalVram: 0,
            usedVram: 0,
            freeVram: 0,
            temperature: 0.0,
            utilization: 0.0
        })

    // Lists
    property var disks: []      // [{name, totalSpace, availableSpace, kind, fileSystem, mountPoint}]
    property var network: []    // [{name, receivedBytes, transmittedBytes}]

    // Helper properties
    property real cpuUsagePercent: cpu.usage
    property real memoryUsagePercent: memory.total > 0 ? (memory.used / memory.total) * 100 : 0
    property real gpuUsagePercent: gpu.utilization
    property string uptimeFormatted: formatUptime(uptime)
    function formatUptime(seconds) {
        let h = Math.floor(seconds / 3600);
        let m = Math.floor((seconds % 3600) / 60);
        let s = seconds % 60;
        return `${h}h ${m}m ${s}s`;
    }

    Socket {
        id: socket
        path: root.path
        connected: true
        onConnectedChanged: {
            write('hardware\n');
        }
        parser: SplitParser {
            onRead: line => {
                root._handleLine(line);
            }
        }
        onError: err => {
            root.lastError = err;
        }
    }

    function _handleLine(line) {
        try {
            var data = JSON.parse(line);

            // System info
            root.os = data.os || "";
            root.kernelVersion = data.kernel_version || "";
            root.osVersion = data.os_version || "";
            root.uptime = data.uptime || 0;
            root.bootTime = data.boot_time || 0;

            // CPU
            if (data.cpu) {
                root.cpu = {
                    architecture: data.cpu.cpu_architecture || "",
                    usage: data.cpu.cpu_usage || 0.0,
                    frequency: data.cpu.cpu_frequency || 0,
                    physicalCores: data.cpu.physical_cores || 0,
                    cores: data.cpu.cpu_cores || 0
                };
            }

            // Memory
            if (data.memory) {
                root.memory = {
                    total: data.memory.total_memory || 0,
                    used: data.memory.used_memory || 0,
                    free: data.memory.free_memory || 0,
                    totalSwap: data.memory.total_swap || 0,
                    usedSwap: data.memory.used_swap || 0
                };
            }

            // GPU
            if (data.gpu) {
                root.gpu = {
                    vendor: data.gpu.vendor || "",
                    model: data.gpu.model || "",
                    family: data.gpu.family || "",
                    deviceId: data.gpu.device_id || "",
                    totalVram: data.gpu.total_vram || 0,
                    usedVram: data.gpu.used_vram || 0,
                    freeVram: data.gpu.free_vram || 0,
                    temperature: data.gpu.temperature || 0.0,
                    utilization: data.gpu.utilization || 0.0
                };
            }

            // Disks and Network
            root.disks = data.disks || [];
            root.network = data.network || [];

            root.ready = true;
        } catch (e) {
            root.lastError = e.toString();
            console.error("Parse error:", e);
        }
    }
}
