pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io
import qs.animations

Singleton {
    id: root

    // --- CPU & Memory ---
    property real cpuUsage: 0
    property real totalMemory: 0
    property real usedMemory: 0

    // --- Sensors (temperature) ---
    property real cpuTemperature: 0

    // --- GPU

    property real gpuMemUsage: 0
    property real gpuProcUsage: 0
    property real gpuTemp: 0

    // --- Network ---
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property real networkSpeedMax: 125000000

    // --- Filesystem (/ partition) ---
    property real rootDiskUsage: 0 // in percent

    // --- Load Averages ---
    property real load1: 0
    property real load5: 0
    property real load15: 0

    // --- Animate everything ---
    Behavior on cpuUsage {
        AnimatedNumber {}
    }

    Behavior on gpuMemUsage {
        AnimatedNumber {}
    }
    Behavior on gpuProcUsage {
        AnimatedNumber {}
    }
    Behavior on gpuTemp {
        AnimatedNumber {}
    }

    Behavior on totalMemory {
        AnimatedNumber {}
    }
    Behavior on usedMemory {
        AnimatedNumber {}
    }
    Behavior on downloadSpeed {
        AnimatedNumber {}
    }
    Behavior on uploadSpeed {
        AnimatedNumber {}
    }
    Behavior on rootDiskUsage {
        AnimatedNumber {}
    }
    Behavior on cpuTemperature {
        AnimatedNumber {}
    }

    function formatHardwareStats(cpu, gpu, memory, network, fs, load, sensors) {
        cpuUsage = cpu;

        gpuMemUsage = gpu[0].mem;
        gpuProcUsage = gpu[0].proc;
        gpuTemp = gpu[0].temperature;

        totalMemory = memory.total;
        usedMemory = memory.used;

        if (Array.isArray(network) && network.length > 0) {
            const net = network.find(n => n.interface_name === "enp6s0") ?? network[0];

            downloadSpeed = net.bytes_recv_rate_per_sec || 0;
            uploadSpeed = net.bytes_sent_rate_per_sec || 0;
        }

        // Filesystem (get root mountpoint `/`)
        const rootFs = fs.find(p => p.mnt_point === "/");
        rootDiskUsage = rootFs ? rootFs.percent : 0;

        // Load Averages
        load1 = load.min1 ?? 0;
        load5 = load.min5 ?? 0;
        load15 = load.min15 ?? 0;

        // Sensors → Try to find CPU temp sensor
        let foundTemp = 0;
        for (let i = 0; i < sensors.length; ++i) {
            const s = sensors[i];
            const label = s.label?.toLowerCase() || "";
            if (label.includes("cpu") && s.unit === "C") {
                foundTemp = s.value;
                break;
            }
        }
        cpuTemperature = foundTemp;
    }

    Process {
        id: infoFetcher
        running: true
        command: ["sh", "-c", "glances --stdout-json cpu,gpu,mem,fs,load,network,sensors | jq -c"]

        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data);

                    const cpu = json.cpu?.total ?? 0;
                    const gpu = json.gpu ?? {};
                    const memory = json.mem ?? {};
                    const network = json.network ?? {};
                    const fs = json.fs ?? [];
                    const load = json.load ?? {};
                    const sensors = json.sensors ?? [];

                    root.formatHardwareStats(cpu, gpu, memory, network, fs, load, sensors);
                } catch (e) {
                    console.warn("Failed to parse hardware stats:", e);
                }
            }
        }
    }


}
