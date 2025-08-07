// Helpers.qml
pragma Singleton
import QtQuick 2.15

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
}
