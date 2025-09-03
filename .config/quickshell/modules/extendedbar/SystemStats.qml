import QtQuick
import QtQuick.Layouts

import qs.services
import qs.components
import qs.assets
import qs.utils
import qs

GridLayout {
    anchors.fill: parent
    columns: Math.max(1, Math.floor(width / 100))

    // CPU panel
    StatPanel {
        headerIcon: "\ue322"
        headerText: "CPU"
        usageValue: (SystemResource.cpuUsage * 100).toFixed(2) + "%"
        usagePercent: 0.69 // For the progress bar
        minValue: "10%"
        maxValue: "100%"
        isTempVisible: true
        tempValue: "65°C"
        isFrequencyVisible: true
        freqValue: "3.0 GHz"
    }
    // GPU panel
    StatPanel {
        headerIcon: "\uef5b"
        headerText: "GPU"
        usageValue: "69%"
        usagePercent: 0.69 // For the progress bar
        minValue: "10%"
        maxValue: "100%"
        isTempVisible: true
        tempValue: "65°C"
        isFrequencyVisible: true
        freqValue: "3.0 GHz"
    }

    // Ram panel
    StatPanel {
        headerIcon: "\uf7a3"
        headerText: "Memory"
        usageLabel: "Memory Usage"
        usageValue: (SystemResource.memoryUsedPercentage * 100).toFixed(1) + "%"
        usagePercent: SystemResource.memoryUsedPercentage
        minValue: formatGB(SystemResource.memoryUsed)
        maxValue: formatGB(SystemResource.memoryTotal)
    }

    // Swap panel
    StatPanel {
        headerIcon: "\ue1db"
        headerText: "Swap"
        usageLabel: "Swap Usage"
        usageValue: "69%"
        usagePercent: 0.69 // For the progress bar
        minValue: "10%"
        maxValue: "100%"
        freqValue: "3.0 GHz"
    }

    function formatGB(value) {
        return (value / (1024 * 1024)).toFixed(2) + " GB";
    }

    // Rectangle {
    //     radius: 10
    //     Layout.fillWidth: true
    //     Layout.fillHeight: true
    //     color: "transparent"

    //     function formatGB(value) {
    //         return (value / (1024 * 1024)).toFixed(2) + " GB";
    //     }

    //     ColumnLayout {
    //         anchors.centerIn: parent

    //         Text {
    //             font.family: FontAssets.fontAwesomeRegular
    //             text: "\uf2db"
    //             font.pixelSize: 24
    //             color: Assets.color14
    //             Layout.alignment: Qt.AlignHCenter
    //         }

    //         Text {
    //             color: Assets.color14
    //             text: (SystemResource.cpuUsage * 100).toFixed(1) + "%"
    //         }
    //     }

    //     Text {
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.bottom: parent.bottom
    //         anchors.bottomMargin: 4

    //         wrapMode: Text.Wrap
    //         horizontalAlignment: Text.AlignHCenter
    //         font.pixelSize: 10
    //         color: Assets.color14
    //         text: 'Cpu Usage'
    //     }

    //     Gauge {
    //         value: SystemResource.cpuUsage * 100
    //         backgroundColor: Assets.color2
    //         foregroundColor: Assets.color15
    //         smoothRepaint: parentGrid.visible
    //     }
    // }

    // Rectangle {
    //     radius: 10
    //     Layout.fillWidth: true
    //     Layout.fillHeight: true
    //     color: "transparent"
    //     ColumnLayout {
    //         anchors.centerIn: parent

    //         Text {
    //             text: qsTr(`\uf093 ${SystemResource.netUpload}`)
    //             color: Assets.color14
    //         }

    //         Text {
    //             text: qsTr(`\uf019 ${SystemResource.netDownload}`)
    //             color: Assets.color14
    //         }
    //     }
    // }
}
