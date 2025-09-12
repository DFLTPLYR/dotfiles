// Helpers.qml
pragma Singleton
import QtQuick 2.15
import "./ntc.js" as NTC

QtObject {
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
            ColorPalette.push(getHexColorName(hex.color));
        }
        return Colors;
    }
}
