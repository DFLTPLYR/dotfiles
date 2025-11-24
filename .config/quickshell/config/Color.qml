pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    FileView {
        id: fileView
        path: Qt.resolvedUrl("./services/colors.json")
        watchChanges: true
        onLoaded: {
            try {
                JSON.parse(text());
            } catch (e) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }
        onFileChanged: {
            reload();
        }
        onLoadFailed: {
            setText("{}");
            fileView.writeAdapter();
        }
        onAdapterUpdated: writeAdapter()
        JsonAdapter {
            id: adapter
            property ColorAdapter color: ColorAdapter {}
        }
    }

    property color background: fileView.adapter.color.background
    property color foreground: fileView.adapter.color.foreground
    property color color0: fileView.adapter.color.color0
    property color color1: fileView.adapter.color.color1
    property color color2: fileView.adapter.color.color2
    property color color3: fileView.adapter.color.color3
    property color color4: fileView.adapter.color.color4
    property color color5: fileView.adapter.color.color5
    property color color6: fileView.adapter.color.color6
    property color color7: fileView.adapter.color.color7
    property color color8: fileView.adapter.color.color8
    property color color9: fileView.adapter.color.color9
    property color color10: fileView.adapter.color.color10
    property color color11: fileView.adapter.color.color11
    property color color12: fileView.adapter.color.color12
    property color color13: fileView.adapter.color.color13
    property color color14: fileView.adapter.color.color14
    property color color15: fileView.adapter.color.color15
    property color primary: fileView.adapter.color.color12
    property color secondary: fileView.adapter.color.color10
    property color accent: fileView.adapter.color.color13
    property color text: fileView.adapter.color.foreground
    property color textSecondary: fileView.adapter.color.color8
    property color border: fileView.adapter.color.color0
    property color success: fileView.adapter.color.color2
    property color warning: fileView.adapter.color.color11
    property color error: fileView.adapter.color.color1
}
