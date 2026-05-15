pragma ComponentBehavior: Bound
import QtQuick
import qs.components

QtObject {
    id: property
    property Menu menu: Menu {
        width: 100
        height: contentHeight
        closePolicy: Popup.NoAutoClose
        onOpened: {
            const config = parent.slotConfig;
            const side = config.side;
            if (side) {
                x = parent.width;
            } else {
                y = parent.height;
            }
        }

        Button {
            width: parent.width
            height: 40
            onClicked: {}
        }
    }

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
                this[k] = object[k]; // assign unconditionally
            }
        }
    }
}
