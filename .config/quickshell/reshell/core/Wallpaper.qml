pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config
    property bool ready: false
    property bool enableSetting: false
    property alias config: adapter.config
    signal generatecolor

    property ListModel list: ListModel {
        id: wallpaperModel

        function save() {
            const list = [];
            for (let i = 0; i < count; i++) {
                const object = wallpaperModel.get(i);
                list.push(JSON.parse(JSON.stringify(object)));
            }
            adapter.container = [...list];
            fileview.save();
        }

        function sync() {
            wallpaperModel.clear();
            const current = adapter.config.current;
            const theme = adapter.config.preset.find(s => s.name === current);
            const sources = theme.source;

            for (const i in sources) {
                wallpaperModel.append(sources[i]);
            }
        }
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl("data/wallpaper.json")
        watchChanges: true
        preload: true
        onLoaded: {
            wallpaperModel.sync();
            config.ready = true;
        }
        onFileChanged: {
            reload();
        }

        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                fileView.setText("{}");
                fileView.writeAdapter();
            }
        }

        adapter: JsonAdapter {
            id: adapter
            property JsonObject config: JsonObject {
                property string mode: "standard"
                property string current: ""
                property list<var> source: []
                property list<var> preset: []
                property list<var> layers: []
                property list<var> containers: []
                property string theme: "scheme-content"
            }
        }
    }

    function save() {
        fileView.writeAdapter();
        config.generatecolor();
    }
}
