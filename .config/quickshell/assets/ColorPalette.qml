import QtQuick
import Quickshell.Io
// ColorPalette.qml
pragma Singleton

Item {
    id: root

    property var colors: {
    }
    // make these writable so Behaviors can be attached
    property color foreground: (colors && colors.foreground) || "#F2FCCA"
    property color background: (colors && colors.background) || "#282523"
    property color backgroundAlt: (colors && colors.backgroundAlt) || "transparent"
    property color cursor: (colors && colors.cursor) || "#C7CAA3"
    // palette 0..15 as writable, animated properties
    property color color0: (colors && colors.color0) || "#4E4A48"
    property color color1: (colors && colors.color1) || "#016355"
    property color color2: (colors && colors.color2) || "#75725D"
    property color color3: (colors && colors.color3) || "#378F86"
    property color color4: (colors && colors.color4) || "#88A529"
    property color color5: (colors && colors.color5) || "#9CAB57"
    property color color6: (colors && colors.color6) || "#A4B94D"
    property color color7: (colors && colors.color7) || "#E5F2AA"
    property color color8: (colors && colors.color8) || "#A0AA77"
    property color color9: (colors && colors.color9) || "#028472"
    property color color10: (colors && colors.color10) || "#9D987C"
    property color color11: (colors && colors.color11) || "#49BEB3"
    property color color12: (colors && colors.color12) || "#B6DC37"
    property color color13: (colors && colors.color13) || "#CFE474"
    property color color14: (colors && colors.color14) || "#DBF766"
    property color color15: (colors && colors.color15) || "#E5F2AA"
    property color primary: color12
    property color secondary: color10
    property color accent: color13
    property color text: foreground
    property color textSecondary: color8
    property color border: color0
    property color success: color2
    property color warning: color11
    property color error: color1

    signal parseDone()

    FileView {
        id: colorJson

        path: Qt.resolvedUrl("../services/colors.json")
        preload: true
        watchChanges: true
        onFileChanged: this.reload()
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

                root.parseDone();
            } catch (e) {
                console.warn("Failed to parse colors.json:", e);
            }
            console.warn("Parsed");
        }
    }

    component ColorAnim: ColorAnimation {
        duration: 300
        easing.type: Easing.InOutQuad
    }

    Behavior on foreground {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on background {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on backgroundAlt {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on cursor {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color0 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color1 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color2 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color3 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color4 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color5 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color6 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color7 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color8 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color9 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color10 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color11 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color12 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color13 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color14 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on color15 {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on primary {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on secondary {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on accent {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on text {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on textSecondary {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on border {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on success {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on warning {
        AnimationProvider.ColorAnim {
        }

    }

    Behavior on error {
        AnimationProvider.ColorAnim {
        }

    }

}
