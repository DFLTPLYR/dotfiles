import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.modules

import qs.types

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: panel
        required property ShellScreen modelData
        screen: modelData

        color: "transparent"

        anchors {
            top: fileView.adapter.position === "top"
            bottom: fileView.adapter.position === "bottom"
            left: fileView.adapter.position === "left"
            right: fileView.adapter.position === "right"
        }

        implicitHeight: screen.height
        implicitWidth: screen.width

        exclusiveZone: fileView.adapter.side ? navbar.width : navbar.height
        exclusionMode: ExclusionMode.Normal

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: `Top-${screen.name}`

        mask: Region {
            regions: [
                Region {
                    item: Global.enableSetting ? floatingWindow : null
                },
                Region {
                    item: navbar
                }
            ]
        }

        Navbar {
            id: navbar
        }

        Settings {
            id: floatingWindow
        }

        Connections {
            target: Quickshell
            function onReloadCompleted() {
                fileView.reslot();
            }
        }

        FileView {
            id: fileView
            path: Qt.resolvedUrl(`./core/${screen.name}.json`)
            watchChanges: true
            preload: true

            property list<Item> slots: []
            property list<Item> widgets: []

            onSlotsChanged: {
                fileView.reslot();
            }
            onWidgetsChanged: {
                fileView.reslot();
            }

            function reslot() {
                const sorted = [...widgets].sort((a, b) => {
                    const targetA = adapter.widgets.find(s => s.name === a.objectName);
                    const targetB = adapter.widgets.find(s => s.name === b.objectName);
                    return (targetA?.position ?? Infinity) - (targetB?.position ?? Infinity);
                });
                for (const widget of sorted) {
                    const target = adapter.widgets.find(s => s.name === widget.objectName);
                    if (target !== undefined) {
                        const slot = slots.find(s => s.objectName === target.slot);
                        widget.parent = slot;
                    }
                }
            }

            function snapHistory() {
                const key = `${screen.name}-navbar`;
                const history = {
                    height: adapter.height,
                    width: adapter.width,
                    position: adapter.position,
                    fill: {
                        enable: adapter.fill.enable,
                        height: adapter.fill.height,
                        width: adapter.fill.width,
                        axis: adapter.fill.axis
                    },
                    style: {
                        color: adapter.style.color,
                        border: {
                            width: adapter.style.border.width,
                            color: adapter.style.border.color
                        },
                        margin: {
                            top: adapter.style.margin.top,
                            bottom: adapter.style.margin.bottom,
                            left: adapter.style.margin.left,
                            right: adapter.style.margin.right
                        },
                        rounding: {
                            topLeft: adapter.style.rounding.topLeft,
                            topRight: adapter.style.rounding.topRight,
                            bottomLeft: adapter.style.rounding.bottomLeft,
                            bottomRight: adapter.style.rounding.bottomRight
                        }
                    },
                    layouts: JSON.parse(JSON.stringify(adapter.layouts)),
                    widgets: JSON.parse(JSON.stringify(adapter.widgets))
                };
                const existing = Global.fileManager.find(s => s && s.subject === key);
                if (existing) {
                    existing.history = history;
                } else {
                    Global.fileManager.push({
                        ref: fileView,
                        subject: key,
                        history: history
                    });
                }
            }

            function rollbackHistory() {
                const key = `${screen.name}-navbar`;
                const entry = Global.fileManager.find(s => s && s.subject === key);
                const history = entry?.history;
                if (!history)
                    return;
                adapter.height = history.height;
                adapter.width = history.width;
                adapter.position = history.position;
                adapter.fill.enable = history.fill.enable;
                adapter.fill.height = history.fill.height;
                adapter.fill.width = history.fill.width;
                adapter.fill.axis = history.fill.axis;
                adapter.style.color = history.style.color;
                adapter.style.border.width = history.style.border.width;
                adapter.style.border.color = history.style.border.color;
                adapter.style.margin.top = history.style.margin.top;
                adapter.style.margin.bottom = history.style.margin.bottom;
                adapter.style.margin.left = history.style.margin.left;
                adapter.style.margin.right = history.style.margin.right;
                adapter.style.rounding.topLeft = history.style.rounding.topLeft;
                adapter.style.rounding.topRight = history.style.rounding.topRight;
                adapter.style.rounding.bottomLeft = history.style.rounding.bottomLeft;
                adapter.style.rounding.bottomRight = history.style.rounding.bottomRight;
                adapter.layouts = JSON.parse(JSON.stringify(history.layouts));
                adapter.widgets = JSON.parse(JSON.stringify(history.widgets));
                Quickshell.reload(false);
            }

            function save() {
                fileView.writeAdapter();
                fileView.snapHistory();
                reload();
            }

            function getDiff() {
                const key = `${screen.name}-navbar`;
                const entry = Global.fileManager.find(s => s && s.subject === key);
                const history = entry?.history;
                if (!history)
                    return null;
                const current = {
                    height: adapter.height,
                    width: adapter.width,
                    position: adapter.position,
                    fill: {
                        enable: adapter.fill.enable,
                        height: adapter.fill.height,
                        width: adapter.fill.width,
                        axis: adapter.fill.axis
                    },
                    style: {
                        color: adapter.style.color,
                        border: {
                            width: adapter.style.border.width,
                            color: adapter.style.border.color
                        },
                        margin: {
                            top: adapter.style.margin.top,
                            bottom: adapter.style.margin.bottom,
                            left: adapter.style.margin.left,
                            right: adapter.style.margin.right
                        },
                        rounding: {
                            topLeft: adapter.style.rounding.topLeft,
                            topRight: adapter.style.rounding.topRight,
                            bottomLeft: adapter.style.rounding.bottomLeft,
                            bottomRight: adapter.style.rounding.bottomRight
                        }
                    },
                    layouts: adapter.layouts,
                    widgets: adapter.widgets
                };

                const diff = {};

                function compare(prefix, a, b) {
                    for (const key in a) {
                        const fullKey = prefix ? `${prefix}.${key}` : key;
                        if (typeof a[key] === 'object' && a[key] !== null && !Array.isArray(a[key])) {
                            compare(fullKey, a[key], b[key]);
                        } else if (Array.isArray(a[key])) {
                            if (JSON.stringify(a[key]) !== JSON.stringify(b[key])) {
                                diff[fullKey] = {
                                    from: b[key],
                                    to: a[key]
                                };
                            }
                        } else if (a[key] !== b[key]) {
                            diff[fullKey] = {
                                from: b[key],
                                to: a[key]
                            };
                        }
                    }
                }
                compare('', current, history);
                return diff;
            }

            onLoaded: snapHistory()

            onFileChanged: {
                reload();
                snapHistory();
            }

            onLoadFailed: error => {
                if (error === FileViewError.FileNotFound) {
                    fileView.setText("{}");
                    fileView.writeAdapter();
                }
            }

            adapter: JsonAdapter {
                id: adapter
                property int height: 40
                property int width: 40
                property JsonObject fill: JsonObject {
                    property bool enable: false
                    property int height: 10
                    property int width: 100
                    property int axis: 0
                }
                property string position: "top"
                readonly property bool side: position === "left" || position === "right"
                property StyleJson style: StyleJson {
                    color: Colors.color.background
                    border {
                        width: 1
                        color: Colors.color.primary
                    }
                }
                property list<var> layouts: []
                property list<var> widgets: []

                onWidgetsChanged: {
                    Qt.callLater(() => {
                        fileView.reslot();
                    });
                }
            }

            Component.onCompleted: snapHistory()
        }
    }
}
