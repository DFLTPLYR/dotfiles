pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config
    property bool enableSetting: false
    property alias config: adapter.config

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./wallpaper.json")
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
        adapter: JsonAdapter {
            id: adapter
            property JsonObject config: JsonObject {
                property string mode: "standard"
                property list<var> source: []
            }
        }
    }

    function save() {
        fileView.writeAdapter();
    }
}
