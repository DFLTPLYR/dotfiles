pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

import qs.types

Singleton {
    id: config
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
    property bool wallpaper: false
    property bool properties: false
    property bool docks: true

    // global item
    property alias general: adapter
    property list<var> widgets: []

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

            property BorderJson border: BorderJson {
                color: Colors.color.primary
                width: 1
            }
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
            // set it to 0.0 hehe haha moment
            property real opacity: 0.5
            property bool greeter: false
            property list<var> widgets: []
            property int notificationTimer: 5000
        }
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
            return (stateRounding ? stateRounding.bottomLeft : 0) + adapter.rounding.bottomLeft;
        });
        rect.bottomRightRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.bottomRight : 0) + adapter.rounding.bottomRight;
        });
        rect.topLeftRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.topLeft : 0) + adapter.rounding.topLeft;
        });
        rect.topRightRadius = Qt.binding(function () {
            return (stateRounding ? stateRounding.topRight : 0) + adapter.rounding.topRight;
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
                    config.widgets = [...config.widgets, widget];
                }
            }
        }
    }
}
