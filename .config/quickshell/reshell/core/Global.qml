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
    property bool properties: false
    property bool docks: true

    // global item
    property bool hasConnection: false
    property alias general: adapter
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

            Notification.send({
                appname: "Shell",
                title: `State Update`,
                body: `State Change  ${stateNames[config.state]}`,
                icon: "view-grid",
                timeout: 5000
            });
        }
        function sendNotification(appname: string, title: string, body: string, icon: string, timeout: int): void {
            Notification.send({
                appname,
                title,
                body,
                icon,
                timeout
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
            ColorGen.configPath = `${StandardPaths.writableLocation(StandardPaths.ConfigLocation)}/matugen/templates/themed/`;
            ColorGen.generate(paths, Background.config.theme);
            readyBg = [];
        }
    }

    Connections {
        target: ColorGen
        function onError(message) {
            console.log("ColorGen error:", message);
        }
        function onOutput(data) {
            // console.log("ColorGen output:", data);
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

    function apply(target, data) {
        for (const key of Object.keys(data)) {
            if (data[key] === undefined || data[key] === null || target[key] === undefined || target[key] === null)
                continue;
            if (typeof target[key] === "function")
                continue;
            if (typeof target[key] === "object" && typeof data[key] === "object")
                apply(target[key], data[key]);
            else
                target[key] = data[key];
        }
    }

    function save() {
        fileView.writeAdapter();
    }

    function getConfig(monitor) {
        for (var i = 0; i < configs.length; i++) {
            if (monitor && configs[i].screen === monitor) {
                return configs[i].config;
            } else {
                return configs[0].config;
            }
        }
        return null;
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
                const name = fileName.replace(/\.(desktop|dock)\.qml$/, '').replace(/\.qml$/, '');
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
