pragma ComponentBehavior: Bound
import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQml.Models
import qs.core
import qs.components

QtObject {
    id: root
    property var sharedContext
    property PropertyMenu menu: PropertyMenu {}

    component PropertyMenu: Menu {
        id: menu
        property var originalValues: []
        property bool hasChanges: false
        signal entered
        signal exited(bool hasChanges)
        signal remove

        title: "Properties"
        width: 200
        height: contentHeight
        leftPadding: 5

        onOpened: {
            const source = sharedContext && Object.keys(sharedContext).length > 0 ? sharedContext : root;
            const old = Utils.keys(source);
            const _orig = [];
            for (const i in old) {
                const val = {
                    prop: old[i].property,
                    val: source[old[i].property]
                };
                _orig.push(val);
            }
            menu.originalValues = _orig;
            menu.entered();
        }

        function updateHasChanges() {
            const source = sharedContext && Object.keys(sharedContext).length > 0 ? sharedContext : root;
            const current = Utils.keys(source);
            for (const i in current) {
                const prop = current[i].property;
                const orig = menu.originalValues.find(v => v.prop === prop);
                if (!orig || source[prop] !== orig.val) {
                    menu.hasChanges = true;
                    return;
                }
            }
            menu.hasChanges = false;
        }

        onClosed: {
            menu.updateHasChanges();
            menu.exited(menu.hasChanges);
        }

        Instantiator {
            id: propertiesInstantiator
            model: ScriptModel {
                values: {
                    return Utils.getSettings(root);
                }
            }
            delegate: PropertyItems {}
            onObjectAdded: (idx, obj) => {
                menu.insertItem(0, obj);
            }
        }

        Action {
            text: "remove"
            onTriggered: {
                menu.remove();
            }
        }

        Timer {
            id: updateLoop
            interval: 1000
            onTriggered: menu.updateHasChanges()
        }
    }

    component PropertyItems: DelegateChooser {
        role: "type"

        DelegateChoice {
            roleValue: "number"
            PropertyItem {
                required property var modelData
                Label {
                    text: modelData.property
                }

                SpinBox {
                    width: parent.width / 2
                    value: {
                        if (root.sharedContext && root.sharedContext[modelData.property] !== undefined)
                            return root.sharedContext[modelData.property];
                        return root[modelData.property] ?? 0;
                    }
                    onValueChanged: {
                        const target = (root.sharedContext && root.sharedContext[modelData.property] !== undefined) ? root.sharedContext : root;
                        if (target[modelData.property] !== value) {
                            target[modelData.property] = value;
                            updateLoop.restart();
                        }
                    }
                }
            }
        }

        DelegateChoice {
            roleValue: "string"

            PropertyItem {
                required property var modelData

                Label {
                    text: modelData.property
                }
                TextField {
                    width: parent.width
                    text: root[modelData.property]
                    onTextEdited: {
                        const target = (root.sharedContext && root.sharedContext[modelData.property] !== undefined) ? root.sharedContext : root;
                        if (target[modelData.property] !== text) {
                            target[modelData.property] = text;
                            updateLoop.restart();
                        }
                    }
                }
            }
        }
    }

    component PropertyItem: Item {
        id: prop
        default property alias content: col.data
        height: col.height

        Column {
            id: col
            width: parent.width
        }
    }
}
