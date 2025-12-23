// Helpers.qml
pragma Singleton
import QtQuick
import qs.config
import "./ntc.js" as NTC

QtObject {
    function setOpacity(color, alpha) {
        if (!color)
            return Qt.rgba(0, 0, 0, alpha || 1);

        if (typeof color === "string")
            color = Qt.color(color);

        return Qt.rgba(color.r, color.g, color.b, alpha || 1);
    }

    function getHexColorName(hex) {
        return NTC.ntc.name(hex);
    }

    function rectBounds(item) {
        let p = item.mapToItem(null, 0, 0);
        return {
            x: p.x,
            y: p.y,
            width: item.width,
            height: item.height
        };
    }

    function intersects(a, b) {
        return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
    }

    function getRandomInt(max) {
        return Math.floor(Math.random() * max) + 1;
    }
}
