// Assets.qml
pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    // ...existing code...
    signal parseDone

    property var colors: {}

    // make these writable so Behaviors can be attached
    property color foreground: (colors && colors.foreground) || "#F2FCCA"
    Behavior on foreground {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    property color background: (colors && colors.background) || "#282523"
    Behavior on background {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    property color backgroundAlt: (colors && colors.backgroundAlt) || "transparent"
    Behavior on backgroundAlt {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    property color cursor: (colors && colors.cursor) || "#C7CAA3"
    Behavior on cursor {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    // palette 0..15 as writable, animated properties
    property color color0: (colors && colors.color0) || "#4E4A48"
    Behavior on color0 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color1: (colors && colors.color1) || "#016355"
    Behavior on color1 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color2: (colors && colors.color2) || "#75725D"
    Behavior on color2 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color3: (colors && colors.color3) || "#378F86"
    Behavior on color3 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color4: (colors && colors.color4) || "#88A529"
    Behavior on color4 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color5: (colors && colors.color5) || "#9CAB57"
    Behavior on color5 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color6: (colors && colors.color6) || "#A4B94D"
    Behavior on color6 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color7: (colors && colors.color7) || "#E5F2AA"
    Behavior on color7 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color8: (colors && colors.color8) || "#A0AA77"
    Behavior on color8 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color9: (colors && colors.color9) || "#028472"
    Behavior on color9 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color10: (colors && colors.color10) || "#9D987C"
    Behavior on color10 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color11: (colors && colors.color11) || "#49BEB3"
    Behavior on color11 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color12: (colors && colors.color12) || "#B6DC37"
    Behavior on color12 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color13: (colors && colors.color13) || "#CFE474"
    Behavior on color13 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color14: (colors && colors.color14) || "#DBF766"
    Behavior on color14 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    property color color15: (colors && colors.color15) || "#E5F2AA"
    Behavior on color15 {
        ColorAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
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
        }

        onFileChanged: {
            colorJson.reload();
        }
    }
}
