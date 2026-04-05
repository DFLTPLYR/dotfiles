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

    // states
    readonly property QtObject states: QtObject {
        readonly property int normal: 0
        readonly property int edit: 1
    }
    property int state: states.normal
    readonly property bool edit: state === states.edit
    readonly property bool normal: state === states.normal

    // State
    property bool wallpaper: false
    property bool docks: true

    property var modal: null

    IpcHandler {
        target: "config"
        function cycleState() {
            config.state = (config.state + 1) % 2;
            Quickshell.execDetached({
                command: ["notify-send", "State", config.state === states.normal ? "Normal" : "Edit"]
            });
        }
    }
    //
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
            command: ["quickcli", "generate-palette", "--type", "scheme-content", ...paths]
        });
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
        id: folderModel
        folder: Qt.resolvedUrl("../components/widgets")
        nameFilters: ["*.qml"]
        showDirs: false

        onCountChanged: {
            for (let i = 0; i < count; i++) {
                const fileName = get(i, "fileName");
                if (fileName !== "Wrapper.qml") {
                    const widgetName = fileName;
                    const target = Quickshell.shellPath(`components/widgets/${widgetName}`);
                    propertyCheckerComponent.createObject(config, {
                        path: target,
                        widget: widgetName
                    });
                }
            }
        }
    }

    Component {
        id: propertyCheckerComponent
        FileView {
            property string widget: ""

            function getProperties(content) {
                const regex = /\/\/ properties\n([\s\S]*?)\n\s*\/\/ properties/;
                const match = returnJsonObject(content.match(regex));
                return match;
            }

            function returnJsonObject(match) {
                if (!match)
                    return null;
                const props = {};
                const lines = match[1].trim().split('\n');
                for (let line of lines) {
                    let key, value;
                    if (line.trim().startsWith('property ')) {
                        const parts = line.trim().slice(9).split(':');
                        if (parts.length < 2)
                            continue;
                        key = parts[0].trim().split(' ').pop();
                        value = parts.slice(1).join(':').trim();
                    } else {
                        const colonIdx = line.indexOf(':');
                        if (colonIdx === -1)
                            continue;
                        key = line.slice(0, colonIdx).trim();
                        value = line.slice(colonIdx + 1).trim();
                    }
                    if (value === 'true')
                        value = true;
                    else if (value === 'false')
                        value = false;
                    else if (!isNaN(value) && value !== '')
                        value = Number(value);
                    else if (value.startsWith('"') && value.endsWith('"'))
                        value = value.slice(1, -1);
                    props[key] = value;
                }
                return props;
            }

            onPathChanged: {
                this.reload();
            }
            onLoaded: {
                var props = getProperties(text());
                if (props) {
                    const exist = fileView.adapter.widgets.find(s => s && s.objectName === props.objectName);
                    if (!exist) {
                        fileView.adapter.widgets.push(props);
                        fileView.writeAdapter();
                    }
                }
                this.destroy();
            }
        }
    }
}
