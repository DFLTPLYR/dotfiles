import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components
import qs.assets
import qs.utils
import qs
import qs.animations // Add this import for AnimatedNumber

GridLayout {
    id: root
    anchors.fill: parent
    columns: Math.max(1, Math.floor(width / 100))

    // CPU panel
    StatPanel {
        headerIcon: "\ue322"
        headerText: "CPU"
        usageLabel: "CPU Usage"
        usageValue: (SystemResource.cpuUsage * 100).toFixed(1) + "%"
        usagePercent: SystemResource.cpuUsage
        minValue: (SystemResource.cpuUsage * 100).toFixed(1) + "%"
        maxValue: "100%"
        isTempVisible: true
        tempIcon: "\ue30d"
        tempLabel: "freaky"
        tempValue: SystemResource.cpuCores + " Cores"
        isFrequencyVisible: true
        freqValue: "CTX: " + formatNum(SystemResource.cpuCtxSwitches) + "/s"
    }

    // GPU panel
    StatPanel {
        headerIcon: "\uef5b"
        headerText: "GPU"
        usageLabel: "GPU Usage"
        usageValue: (SystemResource.gpuUsage * 100).toFixed(1) + "%"
        usagePercent: SystemResource.gpuUsage
        minValue: (SystemResource.gpuUsage * 100).toFixed(1) + "%"
        maxValue: "100%"
        isTempVisible: true
        tempIcon: "\ue338"
        tempLabel: "gamer card"
        tempValue: SystemResource.gpuTemp.toFixed(1) + "°C"
        isFrequencyVisible: true
        freqValue: "Mem: " + (SystemResource.gpuMem * 100).toFixed(1) + "%"
    }

    // Ram panel
    StatPanel {
        headerIcon: "\uf7a3"
        headerText: "Memory"
        usageLabel: "Memory Usage"
        usageValue: (SystemResource.memUsage * 100).toFixed(1) + "%"
        usagePercent: SystemResource.memUsage
        minValue: formatGB(SystemResource.memUsed)
        maxValue: formatGB(SystemResource.memTotal)
        isTempVisible: true
        tempLabel: "Cached"
        tempIcon: "\ue335"
        tempValue: formatGB(SystemResource.memCached)
        isFrequencyVisible: true
        freqLabel: "Active"
        freqValue: formatGB(SystemResource.memActive)
    }

    // Swap panel
    StatPanel {
        headerIcon: "\ue1db"
        headerText: "Swap"
        usageLabel: "Swap Usage"
        usageValue: (SystemResource.swapUsage * 100).toFixed(1) + "%"
        usagePercent: SystemResource.swapUsage
        minValue: formatGB(SystemResource.swapUsed)
        maxValue: formatGB(SystemResource.swapTotal)
        isTempVisible: true
        tempLabel: "Swap In"
        tempIcon: "\ue8d4"
        tempValue: formatGB(SystemResource.swapIn)
        isFrequencyVisible: true
        freqLabel: "Swap Out"
        freqValue: formatGB(SystemResource.swapOut)
    }

    function formatGB(value) {
        return (value / (1024 * 1024 * 1024)).toFixed(2) + " GB";
    }

    function formatNum(value) {
        return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }
}
