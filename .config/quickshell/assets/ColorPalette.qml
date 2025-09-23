// ColorPalette.qml
pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    signal parseDone

    property var colors: {}

    component ColorAnim: ColorAnimation {
        duration: 300
        easing.type: Easing.InOutQuad
    }

    // make these writable so Behaviors can be attached
    property color foreground: (colors && colors.foreground) || "#F2FCCA"
    Behavior on foreground {
        AnimationProvider.ColorAnim {}
    }
    property color background: (colors && colors.background) || "#282523"
    Behavior on background {
        AnimationProvider.ColorAnim {}
    }

    property color backgroundAlt: (colors && colors.backgroundAlt) || "transparent"
    Behavior on backgroundAlt {
        AnimationProvider.ColorAnim {}
    }

    property color cursor: (colors && colors.cursor) || "#C7CAA3"
    Behavior on cursor {
        AnimationProvider.ColorAnim {}
    }

    // palette 0..15 as writable, animated properties
    property color color0: (colors && colors.color0) || "#4E4A48"
    Behavior on color0 {
        AnimationProvider.ColorAnim {}
    }
    property color color1: (colors && colors.color1) || "#016355"
    Behavior on color1 {
        AnimationProvider.ColorAnim {}
    }
    property color color2: (colors && colors.color2) || "#75725D"
    Behavior on color2 {
        AnimationProvider.ColorAnim {}
    }
    property color color3: (colors && colors.color3) || "#378F86"
    Behavior on color3 {
        AnimationProvider.ColorAnim {}
    }
    property color color4: (colors && colors.color4) || "#88A529"
    Behavior on color4 {
        AnimationProvider.ColorAnim {}
    }
    property color color5: (colors && colors.color5) || "#9CAB57"
    Behavior on color5 {
        AnimationProvider.ColorAnim {}
    }
    property color color6: (colors && colors.color6) || "#A4B94D"
    Behavior on color6 {
        AnimationProvider.ColorAnim {}
    }
    property color color7: (colors && colors.color7) || "#E5F2AA"
    Behavior on color7 {
        AnimationProvider.ColorAnim {}
    }
    property color color8: (colors && colors.color8) || "#A0AA77"
    Behavior on color8 {
        AnimationProvider.ColorAnim {}
    }
    property color color9: (colors && colors.color9) || "#028472"
    Behavior on color9 {
        AnimationProvider.ColorAnim {}
    }
    property color color10: (colors && colors.color10) || "#9D987C"
    Behavior on color10 {
        AnimationProvider.ColorAnim {}
    }
    property color color11: (colors && colors.color11) || "#49BEB3"
    Behavior on color11 {
        AnimationProvider.ColorAnim {}
    }
    property color color12: (colors && colors.color12) || "#B6DC37"
    Behavior on color12 {
        AnimationProvider.ColorAnim {}
    }
    property color color13: (colors && colors.color13) || "#CFE474"
    Behavior on color13 {
        AnimationProvider.ColorAnim {}
    }
    property color color14: (colors && colors.color14) || "#DBF766"
    Behavior on color14 {
        AnimationProvider.ColorAnim {}
    }
    property color color15: (colors && colors.color15) || "#E5F2AA"
    Behavior on color15 {
        AnimationProvider.ColorAnim {}
    }

    property color primary: color12
    Behavior on primary {
        AnimationProvider.ColorAnim {}
    }

    property color secondary: color10
    Behavior on secondary {
        AnimationProvider.ColorAnim {}
    }

    property color accent: color13
    Behavior on accent {
        AnimationProvider.ColorAnim {}
    }

    property color text: foreground
    Behavior on text {
        AnimationProvider.ColorAnim {}
    }

    property color textSecondary: color8
    Behavior on textSecondary {
        AnimationProvider.ColorAnim {}
    }

    property color border: color0
    Behavior on border {
        AnimationProvider.ColorAnim {}
    }

    property color success: color2
    Behavior on success {
        AnimationProvider.ColorAnim {}
    }

    property color warning: color11
    Behavior on warning {
        AnimationProvider.ColorAnim {}
    }

    property color error: color1
    Behavior on error {
        AnimationProvider.ColorAnim {}
    }

    FileView {
        id: colorJson
        path: Qt.resolvedUrl("../services/colors.json")
        preload: true
        watchChanges: true
        onLoaded: {
            try {
                colors = JSON.parse(colorJson.text());
                if (colors.foreground)
                    foreground = colors.foreground;
                if (colors.background)
                    background = colors.background;
                if (colors.backgroundAlt)
                    backgroundAlt = colors.backgroundAlt;
                if (colors.cursor)
                    cursor = colors.cursor;

                if (colors.color0)
                    color0 = colors.color0;
                if (colors.color1)
                    color1 = colors.color1;
                if (colors.color2)
                    color2 = colors.color2;
                if (colors.color3)
                    color3 = colors.color3;
                if (colors.color4)
                    color4 = colors.color4;
                if (colors.color5)
                    color5 = colors.color5;
                if (colors.color6)
                    color6 = colors.color6;
                if (colors.color7)
                    color7 = colors.color7;
                if (colors.color8)
                    color8 = colors.color8;
                if (colors.color9)
                    color9 = colors.color9;
                if (colors.color10)
                    color10 = colors.color10;
                if (colors.color11)
                    color11 = colors.color11;
                if (colors.color12)
                    color12 = colors.color12;
                if (colors.color13)
                    color13 = colors.color13;
                if (colors.color14)
                    color14 = colors.color14;
                if (colors.color15)
                    color15 = colors.color15;

                parseDone();
            } catch (e) {
                console.warn("Failed to parse colors.json:", e);
            }
            console.warn("Parsed");
        }
    }
}
