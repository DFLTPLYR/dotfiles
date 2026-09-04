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
        width: 180
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
        Properties {
            width: menu.width
            height: 100
            clip: true
            orientation: ListView.Vertical
            boundsBehavior: Flickable.StopAtBounds
            boundsMovement: Flickable.StopAtBounds
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

    component Properties: ListView {
        id: properties
        model: ScriptModel {
            values: {
                return Utils.getSettings(root);
            }
        }

        delegate: DelegateChooser {
            role: "type"

            DelegateChoice {
                roleValue: "number"
                ColumnLayout {
                    required property var modelData
                    height: 50
                    width: ListView.view.width
                    Label {
                        text: modelData.property
                    }
                    SpinBox {
                        Layout.preferredWidth: parent.width / 2
                        Layout.preferredHeight: parent.height / 2
                        value: {
                            if (sharedContext && sharedContext[modelData.property] !== undefined)
                                return sharedContext[modelData.property];
                            return root[modelData.property] ?? 0;
                        }
                        onValueChanged: {
                            const target = (sharedContext && sharedContext[modelData.property] !== undefined) ? sharedContext : root;
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

                Item {
                    id: string

                    required property var modelData
                    height: 50
                    width: ListView.view.width

                    Row {
                        anchors.fill: parent

                        Label {
                            height: parent.height
                            text: string.modelData.property
                        }

                        TextField {
                            width: parent.width
                            placeholderText: {
                                if (sharedContext && sharedContext[string.modelData.property] !== undefined)
                                    return sharedContext[string.modelData.property];
                                return root[string.modelData.property];
                            }
                            onTextChanged: {
                                const target = (sharedContext && sharedContext[string.modelData.property] !== undefined) ? sharedContext : root;
                                target[string.modelData.property] = text;
                                updateLoop.restart();
                            }
                        }
                    }
                }
            }
        }
    }
}
