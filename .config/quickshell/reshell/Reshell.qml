import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.types
import qs.modules

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: reshell
        required property ShellScreen modelData
        implicitWidth: screen.width
        implicitHeight: screen.height

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: `Reshell-${screen.name}`

        screen: modelData
        color: "transparent"

        mask: Region {
            regions: [
                Region {
                    item: settingloader.item
                },
                Region {
                    item: content.item
                }
            ]
        }

        // Wayland Layers
        LazyLoader {
            id: content
            active: fileview.loaded
            component: Item {
                id: display
                // Navbar
                // Top {
                //     screen: reshell.screen
                // }
                // background
                Background {
                    screen: reshell.screen
                }
                // overlay
                Overlay {
                    screen: reshell.screen
                }
                // docks
                Instantiator {
                    model: adapter.docks
                    delegate: Dock {
                        screen: reshell.screen
                        onAddDock: item => {
                            fileview.docklist = fileview.docklist.concat([item]);
                        }
                    }
                    onObjectAdded: (obj, idx) => {
                        obj.parent = display;
                    }
                }
            }
        }

        // settings
        Loader {
            id: settingloader
            property bool shouldShow: Global.enableSetting && Compositor.focusedMonitor === screen.name
            active: false
            sourceComponent: Settings {
                onHidden: {
                    settingloader.active = false;
                }
            }
            onShouldShowChanged: {
                if (shouldShow) {
                    active = true;
                    Global.settingpanel = this.item;
                } else if (item) {
                    item.state = 'hide';
                }
            }
            onLoaded: {
                item.state = 'show';
            }
        }

        // Per monitor data
        Instantiator {
            model: ScriptModel {
                values: [...fileview.adapter.widgets]
            }
            delegate: LazyLoader {
                required property var modelData
                active: true
                source: {
                    if (modelData === undefined)
                        return "";
                    return Quickshell.shellPath(`components/widgets/${modelData.name}.qml`);
                }
                onLoadingChanged: {
                    if (item) {
                        item.objectName = modelData.name;
                        fileview.widgets.push(item);
                    }
                }
            }
        }

        FileView {
            id: fileview
            path: Qt.resolvedUrl(`./core/data/${screen.name}.json`)
            watchChanges: true
            preload: true

            property list<var> docklist: []
            property list<Item> slots: []
            property list<Item> widgets: []

            onSlotsChanged: {
                fileview.reslot();
            }
            onWidgetsChanged: {
                fileview.reslot();
            }

            onLoaded: snapHistory()

            onFileChanged: {
                reload();
                snapHistory();
            }

            onLoadFailed: error => {
                if (error === FileViewError.FileNotFound) {
                    fileview.setText("{}");
                    fileview.writeAdapter();
                    Quickshell.reload(true);
                }
            }

            adapter: JsonAdapter {
                id: adapter
                property int height: 40
                property int width: 100
                property int x: 0
                property int y: 0
                property string position: "top"
                readonly property bool side: position === "left" || position === "right"
                property list<var> docks: []
                property StyleJson style: StyleJson {
                    color: Colors.color.background
                    border {
                        width: 1
                        color: Colors.color.outline
                    }
                    property bool centered: false
                }
                property WallpaperJson wallpaper: WallpaperJson {}
                property list<var> layouts: []
                property list<var> widgets: []

                property JsonObject custom: JsonObject {
                    property list<var> widget: []
                    property list<var> layout: []
                }

                onLayoutsChanged: {
                    Qt.callLater(() => {
                        fileview.reslot();
                    });
                }
            }

            function updateColor() {
                adapter.style.color = Colors.color.background;
                adapter.style.border.color = Colors.color.outline;
            }

            function reslot() {
                const sorted = [...widgets].sort((a, b) => {
                    if (!a || !b)
                        return 0;
                    const targetA = adapter.widgets.find(s => s && s.name && a.objectName && s.name === a.objectName);
                    const targetB = adapter.widgets.find(s => s && s.name && b.objectName && s.name === b.objectName);
                    return (targetA?.position ?? Infinity) - (targetB?.position ?? Infinity);
                });
                for (const widget of sorted) {
                    if (!widget || !widget.objectName)
                        continue;
                    const target = adapter.widgets.find(s => s && s.name && s.name === widget.objectName);
                    if (target && target.slot) {
                        const slot = fileview.slots.find(s => s && s.objectName && s.objectName === target.slot);
                        if (slot)
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
                    x: adapter.x,
                    y: adapter.y,
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
                    custom: {
                        widget: parseJson(adapter.custom.widget),
                        layout: parseJson(adapter.custom.layout)
                    },
                    layouts: parseJson(adapter.layouts),
                    widgets: parseJson(adapter.widgets),
                    wallpaper: parseJson(adapter.wallpaper)
                };
                const existing = Global.fileManager.find(s => s && s.subject === key);
                if (existing) {
                    existing.history = history;
                } else {
                    Global.fileManager.push({
                        ref: fileview,
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
                adapter.x = history.x;
                adapter.y = history.y;
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
                adapter.custom.widget = parseJson(adapter.custom.widget);
                adapter.custom.layout = parseJson(adapter.custom.layout);
                adapter.layouts = parseJson(history.layouts);
                adapter.widgets = parseJson(history.widgets);
                fileview.writeAdapter();
            }

            function parseJson(json) {
                return JSON.parse(JSON.stringify(json));
            }

            function save() {
                fileview.writeAdapter();
                fileview.snapHistory();
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
                    x: adapter.x,
                    y: adapter.y,
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

            Component.onCompleted: snapHistory()
        }

        Connections {
            target: Quickshell
            function onReloadCompleted() {
                fileview.reslot();
            }
        }
    }
}
