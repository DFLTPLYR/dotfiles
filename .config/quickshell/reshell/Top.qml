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

        FileView {
            id: fileView
            path: Qt.resolvedUrl(`./core/${screen.name}.json`)
            watchChanges: true
            preload: true

            function snapHistory() {
                const key = `${screen.name}-navbar`;
                const history = {
                    height: adapter.height,
                    width: adapter.width,
                    position: adapter.position,
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
            }
            Component.onCompleted: snapHistory()
        }
    }
}
