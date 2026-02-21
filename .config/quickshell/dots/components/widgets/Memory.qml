import QtQuick

import qs.config
import qs.components

Wrapper {
    id: wrap
    property string icon: "device-ram-memory"
    property int widgetHeight: 200
    property int widgetWidth: 200
    Row {
        anchors.centerIn: parent
        spacing: 8

        FontIcon {
            text: "device-ram-memory"
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.height, parent.width)
        }

        Text {
            text: `${formatBytes(Hardware.memory.used)} / ${formatBytes(Hardware.memory.total)}`
            color: Colors.color.primary

            font.pixelSize: Math.min(wrap.width, wrap.height) / 4
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
