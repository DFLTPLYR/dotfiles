pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    id: root

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

    function keys(obj) {
        const ks = Object.keys(obj).filter(k => isKeyValid(obj, k));
        return ks.map(k => ({
                    property: k,
                    type: typeof obj[k]
                }));
    }

    function getProperty(obj) {
        const ks = Object.keys(obj).filter(k => isKeyValid(obj, k));
        const keys = {};
        for (const k of ks)
            keys[k] = obj[k];
        return keys;
    }
}
