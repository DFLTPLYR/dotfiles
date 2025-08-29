// Assets.qml
pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    signal parseDone

    property var colors: {}

    readonly property color foreground: (colors && colors.foreground) || "#F2FCCA"
    readonly property color background: (colors && colors.background) || "#282523"
    readonly property color backgroundAlt: (colors && colors.backgroundAlt) || "transparent"
    readonly property color cursor: (colors && colors.cursor) || "#C7CAA3"

    readonly property color color0: (colors && colors.color0) || "#4E4A48"
    readonly property color color1: (colors && colors.color1) || "#016355"
    readonly property color color2: (colors && colors.color2) || "#75725D"
    readonly property color color3: (colors && colors.color3) || "#378F86"
    readonly property color color4: (colors && colors.color4) || "#88A529"
    readonly property color color5: (colors && colors.color5) || "#9CAB57"
    readonly property color color6: (colors && colors.color6) || "#A4B94D"
    readonly property color color7: (colors && colors.color7) || "#E5F2AA"
    readonly property color color8: (colors && colors.color8) || "#A0AA77"
    readonly property color color9: (colors && colors.color9) || "#028472"
    readonly property color color10: (colors && colors.color10) || "#9D987C"
    readonly property color color11: (colors && colors.color11) || "#49BEB3"
    readonly property color color12: (colors && colors.color12) || "#B6DC37"
    readonly property color color13: (colors && colors.color13) || "#CFE474"
    readonly property color color14: (colors && colors.color14) || "#DBF766"
    readonly property color color15: (colors && colors.color15) || "#E5F2AA"

    FileView {
        id: colorJson
        path: Qt.resolvedUrl("../services/colors.json")
        preload: true
        watchChanges: true
        onLoaded: {
            try {
                colors = JSON.parse(colorJson.text());
                parseDone();
            } catch (e) {
                console.warn("Failed to parse colors.json:", e);
            }
        }

        onFileChanged: {
            colorJson.reload();
            console.log('reloaded');
        }
    }
}
