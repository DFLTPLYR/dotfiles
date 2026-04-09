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
    readonly property QtObject states: QtObject {
        readonly property int normal: 0
        readonly property int edit: 1
    }
    property int state: states.normal
    readonly property bool edit: state === states.edit
    readonly property bool normal: state === states.normal

    // Modal State
    property bool wallpaper: false
    property bool properties: false
    property bool docks: true

    property var modal: null

    property bool enableSetting: false
    property bool enableSystemPanel: false
    property Item setttingPanel: null

    property bool widgetpanelEnabled: false
    property var widgetpanelTarget: null

    property bool slotpanelEnabled: false
    property var slotpanelTarget: null

    property var selectedItem: null

    // global item
    property alias general: adapter
    property list<var> fileManager: []
    property list<var> widgets: []

    IpcHandler {
        target: "config"
        function cycleState() {
            config.state = (config.state + 1) % 2;
            Quickshell.execDetached({
                command: ["notify-send", "State", config.state === states.normal ? "Normal" : "Edit"]
            });
        }
    }

    function getConfigManager(tag) {
        const entry = fileManager.find(s => s && s.subject === tag);
        return entry?.ref || null;
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
            property bool moveablesetting: false
            property list<var> widgets: []
            property int notificationTimer: 5000
        }
    }

    function save() {
        fileView.writeAdapter();
        for (const i in fileManager) {
            fileManager[i].ref.save();
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
