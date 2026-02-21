import QtQuick

import qs.config

Wrapper {
    property string icon: "device-ram-memory"
    property int widgetHeight: 100
    property int widgetWidth: 100
    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: `${formatBytes(Hardware.memory.used)} / ${formatBytes(Hardware.memory.total)}`
            color: Colors.color.primary
            function formatBytes(bytes) {
                if (bytes === 0)
                    return "0 B";
                const k = 1024;
                const sizes = ["B", "KB", "MB", "GB", "TB"];
                const i = Math.floor(Math.log(bytes) / Math.log(k));
                return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
            }
        }
    }
}
