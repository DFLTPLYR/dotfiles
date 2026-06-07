pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

Singleton {
    id: config

    property SystemClock clock: SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // signal
    signal colorUpdate

    // states
    readonly property var stateNames: ["Normal", "Edit", "Widget"]
    readonly property QtObject states: QtObject {
        readonly property int normal: 0
        readonly property int edit: 1
        readonly property int widget: 2
    }

    property int state: states.normal
    readonly property bool edit: state === states.edit
    readonly property bool normal: state === states.normal
    readonly property bool widget: state === states.widget

    // Modal State
    property var modal: null
    property bool properties: false
    property bool docks: true

    // global item
    property alias general: adapter
    property list<var> widgets: []
    property list<var> configs: []
    property list<var> settings: [
        {
            "name": "General",
            "page": 0
        },
        {
            "name": "Components",
            "page": 1
        },
        {
            "name": "Wallpaper",
            "page": 2
        }
    ]

    IpcHandler {
        target: "config"
        function cycleState() {
            config.state = (config.state + 1) % stateNames.length;
            Quickshell.execDetached({
                command: ["notify-send", "State", stateNames[config.state]]
            });
        }
    }

    function updateColor() {
        const paths = [];

        for (var i in Quickshell.screens) {
            var target = Quickshell.screens[i];
            paths.push(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${target.name}.jpg`);
        }
        Quickshell.execDetached({
            command: ["quickcli", "generate-palette", "--type", Wallpaper.config.theme, ...paths]
        });
        config.colorUpdate();
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl("data/global.json")
        watchChanges: true
        preload: true

        onFileChanged: {
            reload();
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }

        onSaveFailed: error => console.log(error)

        adapter: JsonAdapter {
            id: adapter
            property bool greeter: false
            property bool darkmode: true
        }
    }

    function save() {
        fileView.writeAdapter();
    }

    function bindMargins(item, margin) {
        item.anchors.topMargin = Qt.binding(function () {
            return margin.top;
        });
        item.anchors.leftMargin = Qt.binding(function () {
            return margin.left;
        });
        item.anchors.rightMargin = Qt.binding(function () {
            return margin.right;
        });
        item.anchors.bottomMargin = Qt.binding(function () {
            return margin.bottom;
        });
    }

    function bindRadii(rect, stateRounding = null) {
        rect.bottomLeftRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.bottomLeft : 0) + Components.config.rounding.bottomLeft;
        });
        rect.bottomRightRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.bottomRight : 0) + Components.config.rounding.bottomRight;
        });
        rect.topLeftRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.topLeft : 0) + Components.config.rounding.topLeft;
        });
        rect.topRightRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.topRight : 0) + Components.config.rounding.topRight;
        });
    }

    FolderListModel {
        folder: Qt.resolvedUrl("../widgets")
        nameFilters: ["*.qml"]
        showDirs: false
        onCountChanged: {
            for (let i = 0; i < count; i++) {
                const fileName = get(i, "fileName");
                if (fileName === "Wrapper.qml") {
                    return;
                }
                const name = fileName.replace(/\.qml$/, '');
                const exist = config.widgets.find(s => s && s.name === name);
                if (!exist) {
                    const path = Quickshell.shellPath(`widgets/${fileName}`);
                    const widget = {
                        name: name,
                        source: path
                    };
                    if (fileName.includes(".dock")) {
                        widget.type = "dock";
                    }
                    if (fileName.includes(".desktop")) {
                        widget.type = "desktop";
                    }
                    config.widgets = [...config.widgets, widget];
                }
            }
        }
    }

    FolderListModel {
        folder: Qt.resolvedUrl("data/themes")
        nameFilters: ["*.json"]
        onCountChanged: {
            for (let i = 0; i < count; i++) {
                const fileName = get(i, "fileName");
                const file = loader.createObject(this, {
                    path: Qt.resolvedUrl(`data/themes/${fileName}`)
                });

                const theme = {
                    name: fileName,
                    light: file.adapter.light,
                    dark: file.adapter.dark
                };
            }
        }
    }

    Component {
        id: loader
        FileView {
            id: file
            watchChanges: true
            preload: true
            blockLoading: true
            onFileChanged: reload()
            adapter: JsonAdapter {
                property JsonObject dark: JsonObject {
                    property color primary: "#b8bb26"
                    property color on_primary: "#282828"
                    property color secondary: "#fabd2f"
                    property color on_secondary: "#282828"
                    property color tertiary: "#83a598"
                    property color on_tertiary: "#282828"
                    property color error: "#fb4934"
                    property color on_error: "#282828"
                    property color surface: "#282828"
                    property color on_surface: "#fbf1c7"
                    property color surface_variant: "#3c3836"
                    property color on_surface_variant: "#ebdbb2"
                    property color outline: "#57514e"
                    property color shadow: "#282828"
                    property color hover: "#83a598"
                    property color on_hover: "#282828"
                    property JsonObject terminal: JsonObject {
                        property JsonObject normal: JsonObject {
                            property color black: "#282828"
                            property color red: "#cc241d"
                            property color green: "#98971a"
                            property color yellow: "#d79921"
                            property color blue: "#458588"
                            property color magenta: "#b16286"
                            property color cyan: "#689d6a"
                            property color white: "#a89984"
                        }
                        property JsonObject bright: JsonObject {
                            property color black: "#928374"
                            property color red: "#fb4934"
                            property color green: "#b8bb26"
                            property color yellow: "#fabd2f"
                            property color blue: "#83a598"
                            property color magenta: "#d3869b"
                            property color cyan: "#8ec07c"
                            property color white: "#ebdbb2"
                        }
                        property color foreground: "#ebdbb2"
                        property color background: "#282828"
                        property color selectionFg: "#ebdbb2"
                        property color selectionBg: "#665c54"
                        property color cursorText: "#282828"
                        property color cursor: "#ebdbb2"
                    }
                }
                property JsonObject light: JsonObject {
                    property color primary: "#98971a"
                    property color on_primary: "#fbf1c7"
                    property color secondary: "#d79921"
                    property color on_secondary: "#fbf1c7"
                    property color tertiary: "#458588"
                    property color on_tertiary: "#fbf1c7"
                    property color error: "#cc241d"
                    property color on_error: "#fbf1c7"
                    property color surface: "#fbf1c7"
                    property color on_surface: "#3c3836"
                    property color surface_variant: "#ebdbb2"
                    property color on_surface_variant: "#7c6f64"
                    property color outline: "#bdae93"
                    property color shadow: "#d5c4a1"
                    property color hover: "#458588"
                    property color on_hover: "#fbf1c7"
                    property JsonObject terminal: JsonObject {
                        property JsonObject normal: JsonObject {
                            property color black: "#fbf1c7"
                            property color red: "#cc241d"
                            property color green: "#98971a"
                            property color yellow: "#d79921"
                            property color blue: "#458588"
                            property color magenta: "#b16286"
                            property color cyan: "#689d6a"
                            property color white: "#7c6f64"
                        }
                        property JsonObject bright: JsonObject {
                            property color black: "#928374"
                            property color red: "#9d0006"
                            property color green: "#79740e"
                            property color yellow: "#b57614"
                            property color blue: "#076678"
                            property color magenta: "#8f3f71"
                            property color cyan: "#427b58"
                            property color white: "#3c3836"
                        }
                        property color foreground: "#3c3836"
                        property color background: "#fbf1c7"
                        property color selectionFg: "#fbf1c7"
                        property color selectionBg: "#3c3836"
                        property color cursorText: "#625e5c"
                        property color cursor: "#3c3836"
                    }
                }
            }
        }
    }
}
