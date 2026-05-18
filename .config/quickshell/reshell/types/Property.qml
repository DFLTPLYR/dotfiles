pragma ComponentBehavior: Bound
import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQml.Models
import qs.core
import qs.components

QtObject {
    id: root

    property Menu menu: Menu {
        id: menu

        signal remove
        width: 200
        height: contentHeight
        leftPadding: 5

        onOpened: {
            var side = parent.slotConfig?.side;
            if (side) {
                x = parent.width;
                y = (parent.height - menu.height) / 2;
            } else {
                y = parent.height;
                x = (parent.width - menu.width) / 2;
            }
        }

        ListView {
            id: properties
            width: menu.width
            height: 100
            clip: true
            orientation: ListView.Vertical

            model: ScriptModel {
                values: {
                    return root.getSettings();
                }
            }

            DelegateChooser {
                id: chooser
                role: "type"

                DelegateChoice {
                    roleValue: "number"
                    RowLayout {
                        required property var modelData
                        height: 50
                        width: parent ? parent.width : 0
                        Label {
                            text: modelData.property
                        }
                        SpinBox {
                            Layout.preferredWidth: parent.width / 2
                            Layout.preferredHeight: parent.height / 2
                            value: root[modelData.property]
                            onValueChanged: {
                                root[modelData.property] = value;
                            }
                        }
                    }
                }

                DelegateChoice {
                    roleValue: "string"
                    RowLayout {
                        required property var modelData
                        height: 50
                        width: parent ? parent.width : 0
                        Label {
                            text: "test"
                        }
                    }
                }

                DelegateChoice {
                    roleValue: "boolean"
                    RowLayout {
                        required property var modelData
                        height: 50
                        width: parent ? parent.width : 0
                        Label {
                            text: "test"
                        }
                    }
                }
            }
            delegate: chooser
        }

        Action {
            text: "remove"
            onTriggered: {
                menu.remove();
            }
        }
    }

    function isKeyValid(k, extraEndings) {
        if (k === "objectName" || k === "menu" || typeof root[k] === "function")
            return false;
        if (k.endsWith("Changed"))
            return false;
        if (typeof root[k] === "undefined")
            return false;
        if (extraEndings?.length) {
            for (const e of extraEndings) {
                if (k.endsWith(e))
                    return false;
            }
        }
        return true;
    }

    function getSettings() {
        const ks = Object.keys(root).filter(k => isKeyValid(k, ["Options"]));
        const keys = ks.map(k => ({
                    property: k,
                    type: typeof root[k]
                }));

        for (const i in keys) {
            const key = keys[i];
            const options = this[key.property + "Options"];
            if (options) {
                key.options = options;
                key.type = "dropdown";
            }
        }

        return keys;
    }

    function keys() {
        const ks = Object.keys(root).filter(k => isKeyValid(k));
        return ks.map(k => ({
                    property: k,
                    type: typeof root[k]
                }));
    }

    function getProperty() {
        const ks = Object.keys(root).filter(k => isKeyValid(k));
        const obj = {};
        for (const k of ks)
            obj[k] = root[k];
        return obj;
    }

    function setProperty(object) {
        for (const k of Object.keys(object)) {
            if (!isKeyValid(k))
                continue;
            let val = object[k];
            if (val !== null && typeof val === "object" && val.value !== undefined)
                val = val.value;
            if (val !== null && typeof val === "object")
                continue;
            root[k] = val;
        }
    }
}
