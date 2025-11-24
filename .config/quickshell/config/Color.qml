pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.config

Singleton {
    FileView {
        id: fileView
        path: Qt.resolvedUrl("../services/colors.json")
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
        onAdapterUpdated: {
            writeAdapter();
        }
        JsonAdapter {
            id: adapter
            property color foreground: "#F2FCCA"
            property color background: "#282523"
            property color backgroundAlt: "transparent"
            property color cursor: "#C7CAA3"
            property color color0: "#4E4A48"
            property color color1: "#016355"
            property color color2: "#75725D"
            property color color3: "#378F86"
            property color color4: "#88A529"
            property color color5: "#9CAB57"
            property color color6: "#A4B94D"
            property color color7: "#E5F2AA"
            property color color8: "#A0AA77"
            property color color9: "#028472"
            property color color10: "#9D987C"
            property color color11: "#49BEB3"
            property color color12: "#B6DC37"
            property color color13: "#CFE474"
            property color color14: "#DBF766"
            property color color15: "#E5F2AA"
            property color primary: color12
            property color secondary: color10
            property color accent: color13
            property color text: foreground
            property color textSecondary: color8
            property color border: color0
            property color success: color2
            property color warning: color11
            property color error: color1
        }
    }

    property color background: fileView.adapter.background
    property color backgroundAlt: fileView.adapter.backgroundAlt
    property color foreground: fileView.adapter.foreground
    property color color0: fileView.adapter.color0
    property color color1: fileView.adapter.color1
    property color color2: fileView.adapter.color2
    property color color3: fileView.adapter.color3
    property color color4: fileView.adapter.color4
    property color color5: fileView.adapter.color5
    property color color6: fileView.adapter.color6
    property color color7: fileView.adapter.color7
    property color color8: fileView.adapter.color8
    property color color9: fileView.adapter.color9
    property color color10: fileView.adapter.color10
    property color color11: fileView.adapter.color11
    property color color12: fileView.adapter.color12
    property color color13: fileView.adapter.color13
    property color color14: fileView.adapter.color14
    property color color15: fileView.adapter.color15
    property color primary: fileView.adapter.color12
    property color secondary: fileView.adapter.color10
    property color accent: fileView.adapter.color13
    property color text: fileView.adapter.foreground
    property color textSecondary: fileView.adapter.color8
    property color border: fileView.adapter.color0
    property color success: fileView.adapter.color2
    property color warning: fileView.adapter.color11
    property color error: fileView.adapter.color1
}
