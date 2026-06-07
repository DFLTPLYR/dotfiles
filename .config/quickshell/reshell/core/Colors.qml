pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "./ntc.js" as NTC

Singleton {
    property var theme: jsonAdapter.theme[Global.general.darkmode ? "dark" : "light"]
    property alias color: jsonAdapter.color
    property alias palette: jsonAdapter.palette
    property list<string> themes: ["scheme-content", "scheme-expressive", "scheme-fidelity", "scheme-fruit-salad", "scheme-monochrome", "scheme-neutral", "scheme-rainbow", "scheme-tonal-spot", "scheme-vibrant"]
    property list<string> colors: ["background", "error", "error_container", "inverse_on_surface", "inverse_primary", "inverse_surface", "on_background", "on_error", "on_error_container", "on_primary", "on_primary_container", "on_primary_fixed", "on_primary_fixed_variant", "on_secondary", "on_secondary_container", "on_secondary_fixed", "on_secondary_fixed_variant", "on_surface", "on_surface_variant", "on_tertiary", "on_tertiary_container", "on_tertiary_fixed", "on_tertiary_fixed_variant", "outline", "outline_variant", "primary", "primary_container", "primary_fixed", "primary_fixed_dim", "scrim", "secondary", "secondary_container", "secondary_fixed", "secondary_fixed_dim", "shadow", "surface", "surface_bright", "surface_container", "surface_container_high", "surface_container_highest", "surface_container_low", "surface_container_lowest", "surface_dim", "surface_tint", "surface_variant", "tertiary", "tertiary_container", "tertiary_fixed", "tertiary_fixed_dim"]
    property list<string> palettes: ["error0", "error5", "error10", "error15", "error20", "error25", "error30", "error35", "error40", "error50", "error60", "error70", "error80", "error90", "error95", "error98", "error99", "error100", "neutral0", "neutral5", "neutral10", "neutral15", "neutral20", "neutral25", "neutral30", "neutral35", "neutral40", "neutral50", "neutral60", "neutral70", "neutral80", "neutral90", "neutral95", "neutral98", "neutral99", "neutral100", "neutral_variant0", "neutral_variant5", "neutral_variant10", "neutral_variant15", "neutral_variant20", "neutral_variant25", "neutral_variant30", "neutral_variant35", "neutral_variant40", "neutral_variant50", "neutral_variant60", "neutral_variant70", "neutral_variant80", "neutral_variant90", "neutral_variant95", "neutral_variant98", "neutral_variant99", "neutral_variant100", "primary0", "primary5", "primary10", "primary15", "primary20", "primary25", "primary30", "primary35", "primary40", "primary50", "primary60", "primary70", "primary80", "primary90", "primary95", "primary98", "primary99", "primary100", "secondary0", "secondary5", "secondary10", "secondary15", "secondary20", "secondary25", "secondary30", "secondary35", "secondary40", "secondary50", "secondary60", "secondary70", "secondary80", "secondary90", "secondary95", "secondary98", "secondary99", "secondary100", "tertiary0", "tertiary5", "tertiary10", "tertiary15", "tertiary20", "tertiary25", "tertiary30", "tertiary35", "tertiary40", "tertiary50", "tertiary60", "tertiary70", "tertiary80", "tertiary90", "tertiary95", "tertiary98", "tertiary99", "tertiary100"]

    function tintColor(color, val = 1) {
        return Global.general.darkmode ? Qt.darker(color, val) : Qt.lighter(color, val);
    }

    FileView {
        path: Qt.resolvedUrl("data/colors.json")
        watchChanges: true
        onFileChanged: reload()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                this.setText("{}");
                this.writeAdapter();
            }
        }
        adapter: JsonAdapter {
            id: jsonAdapter

            readonly property Color color: Color {}
            readonly property Palette palette: Palette {}
            readonly property MaterialPalette theme: MaterialPalette {}
        }
    }

    function setOpacity(color, alpha = 1) {
        if (!color)
            return Qt.rgba(0, 0, 0, alpha);

        if (typeof color === "string")
            color = Qt.color(color);

        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    component Color: JsonObject {
        property color background: "#1e1e2e"
        property color error: "#f38ba8"
        property color error_container: "#f38ba8"
        property color inverse_on_surface: "#cdd6f4"
        property color inverse_primary: "#f5c2e7"
        property color inverse_surface: "#313244"
        property color on_background: "#cdd6f4"
        property color on_error: "#1e1e2e"
        property color on_error_container: "#1e1e2e"
        property color on_primary: "#1e1e2e"
        property color on_primary_container: "#1e1e2e"
        property color on_primary_fixed: "#1e1e2e"
        property color on_primary_fixed_variant: "#f5c2e7"
        property color on_secondary: "#1e1e2e"
        property color on_secondary_container: "#1e1e2e"
        property color on_secondary_fixed: "#1e1e2e"
        property color on_secondary_fixed_variant: "#f5c2e7"
        property color on_surface: "#cdd6f4"
        property color on_surface_variant: "#bac2de"
        property color on_tertiary: "#1e1e2e"
        property color on_tertiary_container: "#1e1e2e"
        property color on_tertiary_fixed: "#1e1e2e"
        property color on_tertiary_fixed_variant: "#f5c2e7"
        property color outline: "#6c7086"
        property color outline_variant: "#585b70"
        property color primary: "#f5c2e7"
        property color primary_container: "#f5c2e7"
        property color primary_fixed: "#f5c2e7"
        property color primary_fixed_dim: "#cba6f7"
        property color scrim: "#00000088"
        property color secondary: "#89b4fa"
        property color secondary_container: "#89b4fa"
        property color secondary_fixed: "#89b4fa"
        property color secondary_fixed_dim: "#74c7ff"
        property color shadow: "#00000066"
        property color surface: "#313244"
        property color surface_bright: "#45475a"
        property color surface_container: "#1e1e2e"
        property color surface_container_high: "#2a2a3c"
        property color surface_container_highest: "#363646"
        property color surface_container_low: "#12121b"
        property color surface_container_lowest: "#0f0f17"
        property color surface_dim: "#1a1a2a"
        property color surface_tint: "#f5c2e7"
        property color surface_variant: "#45475a"
        property color tertiary: "#f9e2af"
        property color tertiary_container: "#f9e2af"
        property color tertiary_fixed: "#f9e2af"
        property color tertiary_fixed_dim: "#f5e0dc"
    }

    component Palette: JsonObject {
        property color error0: "#f38ba8"
        property color error5: "#f38ba8"
        property color error10: "#f38ba8"
        property color error15: "#f38ba8"
        property color error20: "#f38ba8"
        property color error25: "#f38ba8"
        property color error30: "#f38ba8"
        property color error35: "#f38ba8"
        property color error40: "#f38ba8"
        property color error50: "#f38ba8"
        property color error60: "#f38ba8"
        property color error70: "#f38ba8"
        property color error80: "#f38ba8"
        property color error90: "#f38ba8"
        property color error95: "#f38ba8"
        property color error98: "#f38ba8"
        property color error99: "#f38ba8"
        property color error100: "#f38ba8"

        property color neutral0: "#f5e0dc"
        property color neutral5: "#f2d5cf"
        property color neutral10: "#f5e0dc"
        property color neutral15: "#f2d5cf"
        property color neutral20: "#cdd6f4"
        property color neutral25: "#bac2de"
        property color neutral30: "#a6adc8"
        property color neutral35: "#9399b2"
        property color neutral40: "#7f849c"
        property color neutral50: "#6c7086"
        property color neutral60: "#585b70"
        property color neutral70: "#45475a"
        property color neutral80: "#313244"
        property color neutral90: "#1e1e2e"
        property color neutral95: "#181825"
        property color neutral98: "#12121b"
        property color neutral99: "#0f0f17"
        property color neutral100: "#0c0c14"

        property color primary0: "#f5c2e7"
        property color primary5: "#f5c2e7"
        property color primary10: "#f5c2e7"
        property color primary15: "#f5c2e7"
        property color primary20: "#f5c2e7"
        property color primary25: "#f5c2e7"
        property color primary30: "#f5c2e7"
        property color primary35: "#f5c2e7"
        property color primary40: "#f5c2e7"
        property color primary50: "#f5c2e7"
        property color primary60: "#cba6f7"
        property color primary70: "#cba6f7"
        property color primary80: "#cba6f7"
        property color primary90: "#cba6f7"
        property color primary95: "#cba6f7"
        property color primary98: "#cba6f7"
        property color primary99: "#cba6f7"
        property color primary100: "#cba6f7"

        property color secondary0: "#89b4fa"
        property color secondary5: "#89b4fa"
        property color secondary10: "#89b4fa"
        property color secondary15: "#89b4fa"
        property color secondary20: "#89b4fa"
        property color secondary25: "#89b4fa"
        property color secondary30: "#89b4fa"
        property color secondary35: "#89b4fa"
        property color secondary40: "#89b4fa"
        property color secondary50: "#89b4fa"
        property color secondary60: "#74c7ff"
        property color secondary70: "#74c7ff"
        property color secondary80: "#74c7ff"
        property color secondary90: "#74c7ff"
        property color secondary95: "#74c7ff"
        property color secondary98: "#74c7ff"
        property color secondary99: "#74c7ff"
        property color secondary100: "#74c7ff"

        property color tertiary0: "#f9e2af"
        property color tertiary5: "#f9e2af"
        property color tertiary10: "#f9e2af"
        property color tertiary15: "#f9e2af"
        property color tertiary20: "#f9e2af"
        property color tertiary25: "#f9e2af"
        property color tertiary30: "#f9e2af"
        property color tertiary35: "#f9e2af"
        property color tertiary40: "#f9e2af"
        property color tertiary50: "#f9e2af"
        property color tertiary60: "#f5e0dc"
        property color tertiary70: "#f5e0dc"
        property color tertiary80: "#f5e0dc"
        property color tertiary90: "#f5e0dc"
        property color tertiary95: "#f5e0dc"
        property color tertiary98: "#f5e0dc"
        property color tertiary99: "#f5e0dc"
        property color tertiary100: "#f5e0dc"
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
