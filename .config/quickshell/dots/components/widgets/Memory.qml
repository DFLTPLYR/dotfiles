import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    id: mem
    property string icon: "device-ram-memory"
    property int widgetHeight: 200
    property int widgetWidth: 200

    margin {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }

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

        anchors {
            fill: parent
        }

        FontIcon {
            Layout.preferredHeight: Navbar.config.side ? parent.width : parent.height
            Layout.preferredWidth: height
            text: "circuit"
            color: Colors.color.primary
            font.pixelSize: Math.min(width, height)
            fontSizeMode: Text.Fit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Landscape
        Text {
            visible: !Navbar.config.side
            text: `${mem.formatBytes(Hardware.memory.used)} / ${mem.formatBytes(Hardware.memory.total)}`
            color: Colors.color.primary
            wrapMode: Text.Wrap
        }

        // Portrait
        Text {
            visible: Navbar.config.side
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Colors.color.primary
            font.pixelSize: Math.min(mem.contentWidth, mem.contentHeight)
            text: `${mem.formatBytes(Hardware.memory.used, 0)} `
        }

        Text {
            visible: Navbar.config.side
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: Colors.color.primary
            font.pixelSize: Math.min(mem.contentWidth, mem.contentHeight / 2) / 4
            text: `${mem.formatBytes(Hardware.memory.total, 0)}`
        }
    }
}
