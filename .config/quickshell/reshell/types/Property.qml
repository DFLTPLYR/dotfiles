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
        width: 200
        height: contentHeight
        onOpened: {
            const config = parent.slotConfig;
            const side = config.side;
            if (side) {
                x = parent.width;
            } else {
                y = parent.height;
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
                    const ks = Object.keys(root).filter(k => !k.endsWith("Changed") && k !== "objectName" && k !== "menu" && typeof root[k] !== "function");
                    return ks.map(k => ({
                                property: k,
                                type: typeof root[k]
                            }));
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
                            text: "test"
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
    }

    function keys() {
        const ks = Object.keys(root).filter(k => !k.endsWith("Changed") && k !== "objectName" && k !== "menu" && typeof root[k] !== "function");
        return ks.map(k => ({
                    property: k,
                    type: typeof root[k]
                }));
    }

    function getProperty() {
        const ks = Object.keys(root).filter(k => !k.endsWith("Changed") && k !== "objectName" && k !== "menu" && typeof root[k] !== "function");
        return Object.fromEntries(ks.map(k => [k, root[k]]));
    }

    function setProperty(object) {
        for (const k of Object.keys(object)) {
            if (typeof root[k] !== "function") {
                root[k] = object[k].value;
            }
        }
    }
}
