import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    id: mem
    property string icon: "device-ram-memory"
    property int widgetHeight: 200
    property int widgetWidth: 200

    function formatBytes(bytes, point = 2) {
        if (bytes === 0)
            return "0 B";
        const k = 1024;
        const sizes = ["B", "KB", "MB", "GB", "TB"];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(point)) + " " + sizes[i];
    }

    GridLayout {
        columns: Navbar.config.side ? 1 : 2
        rows: Navbar.config.side ? 2 : 1
        anchors.fill: parent

        FontIcon {
            text: "device-ram-memory"
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.width, parent.height)
        }

        // Landscape
        Text {
            visible: !Navbar.config.side
            text: `${mem.formatBytes(Hardware.memory.used)} / ${mem.formatBytes(Hardware.memory.total)}`
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.width, parent.height) / 4
            wrapMode: Text.Wrap
        }

        // Portrait
        Text {
            visible: Navbar.config.side
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Colors.color.primary
            font.pixelSize: Math.min(mem.contentWidth, mem.contentHeight / 2) * 0.3
            text: `${mem.formatBytes(Hardware.memory.used, 0)} `
        }

        Text {
            visible: Navbar.config.side
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Colors.color.primary
            font.pixelSize: Math.min(mem.contentWidth, mem.contentHeight / 2) * 0.3
            text: `${mem.formatBytes(Hardware.memory.total, 0)}`
        }
    }
}
