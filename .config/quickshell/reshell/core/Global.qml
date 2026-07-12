pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Wayland
import Quickshell.Io
import Qt.labs.folderlistmodel
import System

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

    property bool hasConnection: false
    property alias general: adapter
    property alias matugen: matugenProc
    property list<var> widgets: []
    property list<var> configs: []
    readonly property var settings: [
        {
            "type": "button",
            "name": "General",
            "page": 0
        },
        {
            "type": "menu",
            "name": "Components",
            "page": 1,
            "items": ["notification", "polkit", "volume"]
        },
        {
            "type": "button",
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

    property var readyBg: []
    onReadyBgChanged: {
        if (readyBg.length >= Quickshell.screens.length) {
            const paths = [];

            for (var i in Quickshell.screens) {
                var target = Quickshell.screens[i];
                paths.push(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${target.name}.jpg`);
            }
            Colorscheme.generate(paths, Wallpaper.config.theme);
            readyBg = [];
        }
    }

    Process {
        id: matugenProc
        property var color
        onColorChanged: {
            matugenProc.running = true;
        }
        command: {
            const configPath = String(StandardPaths.writableLocation(StandardPaths.ConfigLocation)).replace("file://", "") + "/matugen/themed.toml";
            const jsonStr = JSON.stringify({
                "colors": matugenProc.color
            });
            return ["sh", "-c", `matugen color hex '${matugenProc?.color?.primary}' --config '${configPath}' --import-json-string '${jsonStr}'`];
        }
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
                fileView.writeAdapter();
            }
        }
        adapter: JsonAdapter {
            id: adapter
            property bool greeter: false
            property bool darkmode: true
            property string theme: "gruvbox"
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

    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() {
            if (ToplevelManager?.activeToplevel?.activated) {}
        }
    }

    Connections {
        target: Networking
        function onConnectivityChanged() {
            if (Networking.connectivity === NetworkConnectivity.Full || Networking.connectivity === NetworkConnectivity.Limited) {
                config.hasConnection = true;
            }
        }
    }
}
