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
}
