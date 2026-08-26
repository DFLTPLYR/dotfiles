pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.core

Singleton {
    id: root

    function bindMargins(item, margin) {
        item.anchors.topMargin = Qt.binding(function () {
            return margin.top;
        });
        item.anchors.leftMargin = Qt.binding(function () {
            return margin.left;
        });
        item.anchors.rightMargin = Qt.binding(function () {
            return margin.right;
        });
        item.anchors.bottomMargin = Qt.binding(function () {
            return margin.bottom;
        });
    }

    function bindRadii(rect, stateRounding = null) {
        rect.bottomLeftRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.bottomLeft : 0) + Components.config.rounding.bottomLeft;
        });
        rect.bottomRightRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.bottomRight : 0) + Components.config.rounding.bottomRight;
        });
        rect.topLeftRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.topLeft : 0) + Components.config.rounding.topLeft;
        });
        rect.topRightRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.topRight : 0) + Components.config.rounding.topRight;
        });
    }

    function intersects(a, b) {
        return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
    }

    function isKeyValid(obj, k, extraEndings) {
        if (k === "objectName" || k === "menu" || typeof obj[k] === "function")
            return false;
        if (k.endsWith("Changed"))
            return false;
        if (typeof obj[k] === "undefined")
            return false;
        if (extraEndings?.length) {
            for (const e of extraEndings) {
                if (k.endsWith(e))
                    return false;
            }
        }
        return true;
    }

    function keys(obj, extraEndings = null) {
        const ks = Object.keys(obj).filter(k => isKeyValid(obj, k, extraEndings));
        return ks.map(k => ({
                    property: k,
                    type: typeof obj[k]
                }));
    }

    function getProperty(obj, extraEndings = null) {
        const ks = Object.keys(obj).filter(k => isKeyValid(obj, k, extraEndings));
        const keys = {};
        for (const k of ks)
            keys[k] = obj[k];
        return keys;
    }

    function setProperty(component, prop) {
        for (const k of Object.keys(prop)) {
            if (!Utils.isKeyValid(component, k))
                continue;
            let val = prop[k];
            if (val === undefined || val === null)
                continue;
            if (typeof val === "object" && val.value !== undefined)
                val = val.value;
            if (val === null || typeof val === "object")
                continue;
            if (component[k] !== val)
                component[k] = val;
        }
    }

    function getSettings(obj) {
        const ks = Object.keys(obj).filter(k => Utils.isKeyValid(obj, k, ["Options"]));
        const keys = ks.map(k => ({
                    property: k,
                    type: typeof obj[k]
                }));

        for (const i in keys) {
            const key = keys[i];
            const options = this[key.property + "Options"];
            if (options) {
                key.options = options;
                key.type = "dropdown";
            }
            if (key.property.includes("Font")) {
                key.type = "font";
            }
        }

        return keys;
    }
}
