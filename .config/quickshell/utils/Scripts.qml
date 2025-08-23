// Helpers.qml
pragma Singleton
import QtQuick 2.15
import "./ntc.js" as NTC

QtObject {
    function hexToRgba(hex, alpha) {
        if (!hex || typeof hex !== "string")
            return Qt.rgba(0, 0, 0, alpha || 1);

        if (hex.startsWith("#"))
            hex = hex.slice(1);
        if (hex.length === 3)
            hex = hex.split("").map(c => c + c).join("");
        if (hex.length !== 6)
            return Qt.rgba(0, 0, 0, alpha || 1);

        const r = parseInt(hex.slice(0, 2), 16) / 255;
        const g = parseInt(hex.slice(2, 4), 16) / 255;
        const b = parseInt(hex.slice(4, 6), 16) / 255;
        return Qt.rgba(r, g, b, alpha || 1);
    }

    function setOpacity(color, alpha) {
        // Accepts a Qt.rgba or Qt.color object and returns the same color with new alpha
        if (!color)
            return Qt.rgba(0, 0, 0, alpha || 1);

        // If color is a string, convert to Qt.rgba
        if (typeof color === "string")
            color = Qt.color(color);

        return Qt.rgba(color.r, color.g, color.b, alpha || 1);
    }

    function getHexColorName(hex) {
        return NTC.ntc.name(hex);
    }

    function getAllGroupColorName(array) {
        const Colors = [];
        for (let hex of array) {
            Colors.push(getHexColorName(hex.color));
        }
        return Colors;
    }
}
