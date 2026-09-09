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

    property var fonts: []

    property SystemClock clock: SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Modal State
    property bool properties: false
    property bool docks: true

    // global item
    property bool hasConnection: false
    property alias general: adapter
    property list<var> widgets: []
    property list<var> configs: []

    property var readyBg: []
    onReadyBgChanged: {
        if (readyBg.length >= Quickshell.screens.length) {
            const paths = [];

            for (var i in Quickshell.screens) {
                var target = Quickshell.screens[i];
                paths.push(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${target.name}.jpg`);
            }
            ColorGen.generate(paths);
            readyBg = [];
        }
    }

    property QtObject setting: QtObject {
        property bool visible: false
        property int page: 0
    }

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
            property JsonObject recorder: JsonObject {
                property bool replay: false
                onReplayChanged: {
                    ScreenRec.replay = replay;
                }
                property string monitor: Quickshell.screens[0].name
                onMonitorChanged: {
                    ScreenRec.monitor = monitor;
                }
                property int fps: 60
                property int duration: 30
            }
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

    IpcHandler {
        target: "config"

        function toggleSettings() {
            config.setting.page = 0;
            config.setting.visible = !config.setting.visible;
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

        function clip() {
            ScreenRec.clip();
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

    Connections {
        target: SysFont
        function onListChanged() {
            config.fonts = SysFont.list;
            const families = [];
            for (const obj of SysFont.list) {
                const font = JSON.parse(obj);
            }
        }
    }

    Connections {
        target: ScreenRec
        function onFinished(path) {
            Notification.send({
                appname: "Shell",
                title: `Recording`,
                body: `Saved at -  ${path}`,
                icon: "media-record",
                timeout: 5000
            });
        }
        function onError(err) {
            print(err);
        }
        function onStarted() {
            Notification.send({
                appname: "Shell",
                title: `Recording`,
                body: `Record Started`,
                icon: "media-record",
                timeout: 5000
            });
        }

        function onClipped(path) {
            print("clipped", path);
            Notification.send({
                appname: "Shell",
                title: "Replay",
                body: `Saved at - ${path}`,
                icon: "media-record",
                timeout: 5000
            });
        }
    }

    Connections {
        target: ColorGen
        function onError(message) {
            console.log("ColorGen error:", message);
        }
        function onOutput(data) {
            if (general.theme === "dynamic")
                Colors.dynamic.file.setText(data);
        }
    }
}
