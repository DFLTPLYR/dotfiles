pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import Qt.labs.folderlistmodel

import QtQuick
import Quickshell
import Quickshell.Io
import "./ntc.js" as NTC

Singleton {
    id: config
    property var theme: themes.find(s => Global.general.theme === s.name)[Global.general.darkmode ? "dark" : "light"]
    property list<var> themes: []
    property list<string> colorscheme: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"]

    function tintColor(color, val = 1) {
        return Global.general.darkmode ? Qt.darker(color, val) : Qt.lighter(color, val);
    }

    FolderListModel {
        folder: Qt.resolvedUrl("data/themes")
        nameFilters: ["*.json"]
        onCountChanged: {
            for (let i = 0; i < count; i++) {
                const fileName = get(i, "fileName");
                const file = loader.createObject(this, {
                    path: Qt.resolvedUrl(`data/themes/${fileName}`)
                });
                file.reload();
                const theme = {
                    name: fileName.replace(".json", ""),
                    light: file.adapter.light,
                    dark: file.adapter.dark
                };
                config.themes.push(theme);
            }
        }
    }

    Component {
        id: loader
        FileView {
            id: file
            watchChanges: true
            onFileChanged: reload()
            adapter: JsonAdapter {
                property JsonObject dark: JsonObject {
                    property color primary: "#b8bb26"
                    property color on_primary: "#282828"
                    property color secondary: "#fabd2f"
                    property color on_secondary: "#282828"
                    property color tertiary: "#83a598"
                    property color on_tertiary: "#282828"
                    property color error: "#fb4934"
                    property color on_error: "#282828"
                    property color surface: "#282828"
                    property color on_surface: "#fbf1c7"
                    property color surface_variant: "#3c3836"
                    property color on_surface_variant: "#ebdbb2"
                    property color outline: "#57514e"
                    property color shadow: "#282828"
                    property color hover: "#83a598"
                    property color on_hover: "#282828"
                    property JsonObject terminal: JsonObject {
                        property JsonObject normal: JsonObject {
                            property color black: "#282828"
                            property color red: "#cc241d"
                            property color green: "#98971a"
                            property color yellow: "#d79921"
                            property color blue: "#458588"
                            property color magenta: "#b16286"
                            property color cyan: "#689d6a"
                            property color white: "#a89984"
                        }
                        property JsonObject bright: JsonObject {
                            property color black: "#928374"
                            property color red: "#fb4934"
                            property color green: "#b8bb26"
                            property color yellow: "#fabd2f"
                            property color blue: "#83a598"
                            property color magenta: "#d3869b"
                            property color cyan: "#8ec07c"
                            property color white: "#ebdbb2"
                        }
                        property color foreground: "#ebdbb2"
                        property color background: "#282828"
                        property color selectionFg: "#ebdbb2"
                        property color selectionBg: "#665c54"
                        property color cursorText: "#282828"
                        property color cursor: "#ebdbb2"
                    }
                }
                property JsonObject light: JsonObject {
                    property color primary: "#98971a"
                    property color on_primary: "#fbf1c7"
                    property color secondary: "#d79921"
                    property color on_secondary: "#fbf1c7"
                    property color tertiary: "#458588"
                    property color on_tertiary: "#fbf1c7"
                    property color error: "#cc241d"
                    property color on_error: "#fbf1c7"
                    property color surface: "#fbf1c7"
                    property color on_surface: "#3c3836"
                    property color surface_variant: "#ebdbb2"
                    property color on_surface_variant: "#7c6f64"
                    property color outline: "#bdae93"
                    property color shadow: "#d5c4a1"
                    property color hover: "#458588"
                    property color on_hover: "#fbf1c7"
                    property JsonObject terminal: JsonObject {
                        property JsonObject normal: JsonObject {
                            property color black: "#fbf1c7"
                            property color red: "#cc241d"
                            property color green: "#98971a"
                            property color yellow: "#d79921"
                            property color blue: "#458588"
                            property color magenta: "#b16286"
                            property color cyan: "#689d6a"
                            property color white: "#7c6f64"
                        }
                        property JsonObject bright: JsonObject {
                            property color black: "#928374"
                            property color red: "#9d0006"
                            property color green: "#79740e"
                            property color yellow: "#b57614"
                            property color blue: "#076678"
                            property color magenta: "#8f3f71"
                            property color cyan: "#427b58"
                            property color white: "#3c3836"
                        }
                        property color foreground: "#3c3836"
                        property color background: "#fbf1c7"
                        property color selectionFg: "#fbf1c7"
                        property color selectionBg: "#3c3836"
                        property color cursorText: "#625e5c"
                        property color cursor: "#3c3836"
                    }
                }
            }
        }
    }

    function setOpacity(color, alpha = 1) {
        if (!color)
            return Qt.rgba(0, 0, 0, alpha);

        if (typeof color === "string")
            color = Qt.color(color);

        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    component MaterialPalette: JsonObject {
        property JsonObject dark: JsonObject {
            property color primary: "#b8bb26"
            property color on_primary: "#282828"
            property color secondary: "#fabd2f"
            property color on_secondary: "#282828"
            property color tertiary: "#83a598"
            property color on_tertiary: "#282828"
            property color error: "#fb4934"
            property color on_error: "#282828"
            property color surface: "#282828"
            property color on_surface: "#fbf1c7"
            property color surface_variant: "#3c3836"
            property color on_surface_variant: "#ebdbb2"
            property color outline: "#57514e"
            property color shadow: "#282828"
            property color hover: "#83a598"
            property color on_hover: "#282828"
            property JsonObject terminal: JsonObject {
                property JsonObject normal: JsonObject {
                    property color black: "#282828"
                    property color red: "#cc241d"
                    property color green: "#98971a"
                    property color yellow: "#d79921"
                    property color blue: "#458588"
                    property color magenta: "#b16286"
                    property color cyan: "#689d6a"
                    property color white: "#a89984"
                }
                property JsonObject bright: JsonObject {
                    property color black: "#928374"
                    property color red: "#fb4934"
                    property color green: "#b8bb26"
                    property color yellow: "#fabd2f"
                    property color blue: "#83a598"
                    property color magenta: "#d3869b"
                    property color cyan: "#8ec07c"
                    property color white: "#ebdbb2"
                }
                property color foreground: "#ebdbb2"
                property color background: "#282828"
                property color selectionFg: "#ebdbb2"
                property color selectionBg: "#665c54"
                property color cursorText: "#282828"
                property color cursor: "#ebdbb2"
            }
        }
        property JsonObject light: JsonObject {
            property color primary: "#98971a"
            property color on_primary: "#fbf1c7"
            property color secondary: "#d79921"
            property color on_secondary: "#fbf1c7"
            property color tertiary: "#458588"
            property color on_tertiary: "#fbf1c7"
            property color error: "#cc241d"
            property color on_error: "#fbf1c7"
            property color surface: "#fbf1c7"
            property color on_surface: "#3c3836"
            property color surface_variant: "#ebdbb2"
            property color on_surface_variant: "#7c6f64"
            property color outline: "#bdae93"
            property color shadow: "#d5c4a1"
            property color hover: "#458588"
            property color on_hover: "#fbf1c7"
            property JsonObject terminal: JsonObject {
                property JsonObject normal: JsonObject {
                    property color black: "#fbf1c7"
                    property color red: "#cc241d"
                    property color green: "#98971a"
                    property color yellow: "#d79921"
                    property color blue: "#458588"
                    property color magenta: "#b16286"
                    property color cyan: "#689d6a"
                    property color white: "#7c6f64"
                }
                property JsonObject bright: JsonObject {
                    property color black: "#928374"
                    property color red: "#9d0006"
                    property color green: "#79740e"
                    property color yellow: "#b57614"
                    property color blue: "#076678"
                    property color magenta: "#8f3f71"
                    property color cyan: "#427b58"
                    property color white: "#3c3836"
                }
                property color foreground: "#3c3836"
                property color background: "#fbf1c7"
                property color selectionFg: "#fbf1c7"
                property color selectionBg: "#3c3836"
                property color cursorText: "#625e5c"
                property color cursor: "#3c3836"
            }
        }
    }
}
