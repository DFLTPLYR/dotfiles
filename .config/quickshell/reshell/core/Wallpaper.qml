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

    property FileModel list: FileModel {
        onSaved: arr => {
            const current = adapter.config.current;
            const theme = adapter.config.preset.find(s => s.name === current);
            theme.source = [...arr];
            print(arr);
            fileView.writeAdapter();
            config.generatecolor();
        }
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl("data/wallpaper.json")
        watchChanges: true
        preload: true
        onLoaded: {
            const current = adapter.config.current;
            const theme = adapter.config.preset.find(s => s.name === current);
            const sources = theme.source;
            list.sources = sources;
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
