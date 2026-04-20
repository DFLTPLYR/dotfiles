import QtQuick

QtObject {
    property int position: -1

    function keys() {
        const ks = Object.keys(this).filter(k => !k.endsWith("Changed") && k !== "objectName" && typeof this[k] !== "function");
        const result = [];
        for (const k of ks) {
            const keys = {
                property: k,
                type: typeof this[k]
            };
            result.push(keys);
        }

        return result;
    }

    function getProperty() {
        const ks = Object.keys(this).filter(k => !k.endsWith("Changed") && k !== "objectName" && typeof this[k] !== "function");
        const result = {};
        for (const k of ks) {
            result[k] = this[k];
        }
        return result;
    }

    function setProperty(object) {
        const ks = Object.keys(object);
        for (const k of ks) {
            if (typeof this[k] !== "function") {
                if (this[k])
                    this[k] = object[k];
            }
        }
    }
}
