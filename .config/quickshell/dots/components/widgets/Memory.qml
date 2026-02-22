import QtQuick
import QtQuick.Layouts

import qs.config
import qs.components

Wrapper {
    id: wrap
    property string icon: "device-ram-memory"
    property int widgetHeight: 200
    property int widgetWidth: 200
    property int leftPadding: 10
    property int rightPadding: 10
    property int topPadding: 10
    property int bottomPadding: 10
    property Spacing padding: Spacing {}

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
            leftMargin: Navbar.config.side ? wrap.leftPadding : 10
            rightMargin: Navbar.config.side ? wrap.rightPadding : 10
            topMargin: Navbar.config.side ? wrap.topPadding : 0
            bottomMargin: Navbar.config.side ? wrap.bottomPadding : 0
        }
        // icon
        FontIcon {
            text: "device-ram-memory"
            color: Colors.color.primary
            font.pixelSize: Math.min(parent.height, parent.width)
        }

        // Portrait
        Text {
            visible: !Navbar.config.side
            text: `${wrap.formatBytes(Hardware.memory.used)} / ${wrap.formatBytes(Hardware.memory.total)}`
            color: Colors.color.primary
            font.pixelSize: Math.min(wrap.width, wrap.height) / 4
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        // Column
        Text {
            visible: Navbar.config.side
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Colors.color.primary
            font.pixelSize: Math.min(wrap.width, wrap.height) / 4
            text: `${wrap.formatBytes(Hardware.memory.used, 0)} `
        }

        Rectangle {
            visible: Navbar.config.side
            color: Colors.color.tertiary
            Layout.fillWidth: true
            Layout.preferredHeight: 2
        }

        Text {
            visible: Navbar.config.side
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Colors.color.primary
            font.pixelSize: Math.min(wrap.width, wrap.height) / 4
            text: `${wrap.formatBytes(Hardware.memory.total, 0)}`
        }
    }
}
