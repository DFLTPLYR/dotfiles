pragma ComponentBehavior: Bound
pragma Singleton
import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: config

    property bool ready: false
    property bool enableSetting: false
    property alias config: adapter.config
    property QtObject contextArea: QtObject {
        property point startPoint
        property bool selecting: false
        onSelectingChanged: {
            if (selecting)
                return;
            if (width >= 50 && height >= 50) {
                const box = widgetContainerFactory.createObject(null, {
                    x,
                    y,
                    width,
                    height,
                    z: 0
                });
                config.boxes = [...config.boxes, box];
            }
            width = 0;
            height = 0;
            x = 0;
            y = 0;
        }
        property int width: 0
        property int height: 0
        property int x: 0
        property int y: 0
    }

    property var boxes: []
    property var images: []

    property Component widgetContainerFactory: Component {
        Container {}
    }
    property Component imageContainerFactory: Component {
        Container {
            property string path: ""
            property string type: ""
        }
    }

    component Container: QtObject {
        id: root
        property int x: 0
        property int y: 0
        property int z: 0
        property int width: 0
        property int height: 0
    }

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
                property list<var> wallpapers: []
                property list<var> widgets: []
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
