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

    property FileModel containers: FileModel {
        signal generate
        onSaved: list => {
            const current = adapter.config.current;
            const theme = adapter.config.preset.find(s => s.name === current);
            theme.contents = [...list];
            fileView.writeAdapter();
        }
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl("data/background.json")
        watchChanges: true
        preload: true
        onLoaded: {
            if (containers.count === 0) {
                const current = adapter.config.current;
                const theme = adapter.config.preset.find(s => s.name === current);
                const contents = theme?.contents;
                if (contents) {
                    containers.sources = contents;
                }
            }
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
                property string current: "default"
                property list<var> preset: [
                    {
                        name: "default"
                    }
                ]
                property string theme: "scheme-content"
                onThemeChanged: {
                    config.containers.generate();
                }
            }
        }
    }

    function save() {
        fileView.writeAdapter();
    }
}
