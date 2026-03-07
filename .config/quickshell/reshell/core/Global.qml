pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.types

Singleton {
    id: config
    property bool enableSetting: false
    property alias general: adapter
    property alias icon: customIconFont.font

    // global item
    property list<var> fileManager: []
    property list<var> navbar: []

    function getConfigManager(tag) {
        const entry = fileManager.find(s => s && s.subject === tag);
        return entry?.ref || null;
    }

    FontLoader {
        id: customIconFont
        source: Qt.resolvedUrl("./icon.otf")
    }

    FileView {
        id: fileView
        path: Qt.resolvedUrl("./general.json")
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
            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
            // set it to 0.0 hehe haha moment
            property real opacity: 0.5
            property ButtonJson button: ButtonJson {}
            property SpinBoxJson spinbox: SpinBoxJson {}
            property SwitchJson toggle: SwitchJson {}
            property PageIndicator pageIndicator: PageIndicator {}
            property Slider slider: Slider {}
            property Label label: Label {}
            property Range range: Range {}
        }
    }

    component ButtonJson: JsonObject {
        property JsonObject content: JsonObject {
            property color down: Colors.setOpacity(Colors.color.primary, 1)
            property color up: Colors.setOpacity(Colors.color.primary, 1)
        }
        property JsonObject background: JsonObject {
            property color down: Qt.darker(Colors.color.background, 1.2)
            property color up: Qt.darker(Colors.color.primary, 1)
            property real opacity: 0.5
            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
        }
    }

    component SpinBoxJson: JsonObject {
        property color color: Colors.color.background
        property color text: Colors.color.on_background
        property BorderJson border: BorderJson {}
        property DirectionJson margin: DirectionJson {}
        property CornerJson rounding: CornerJson {}
        property JsonObject hover: JsonObject {
            property color color: Colors.setOpacity(Colors.color.primary, 1)
            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
        }
        property JsonObject unhover: JsonObject {
            property real opacity: 0.5
            property color color: Colors.setOpacity(Colors.color.primary, 0.7)
            property BorderJson border: BorderJson {}
            property DirectionJson margin: DirectionJson {}
            property CornerJson rounding: CornerJson {}
        }
    }

    component SwitchJson: JsonObject {
        property JsonObject content: JsonObject {
            property color color: Colors.color.primary
            property int radius: 13
        }
        property JsonObject indicator: JsonObject {
            property color down: Colors.color.surface_dim
            property color up: Colors.color.surface_bright
            property int radius: 13
            property int width: 48
            property int height: 26
            property JsonObject inner: JsonObject {
                property color down: Colors.color.primary
                property color up: Colors.color.secondary
                property int radius: 13
                property int width: 26
                property int height: 26
            }
        }
    }

    component PageIndicator: JsonObject {
        property int width: 8
        property int height: 8
        property real radius: 4
        property color color: Colors.color.primary
    }

    component Slider: JsonObject {
        property RectangleJson background: RectangleJson {
            height: 4
            width: 200
            color: Colors.color.background
            rounding {
                topLeft: 100
                topRight: 100
                bottomLeft: 100
                bottomRight: 100
            }
            property RectangleJson progress: RectangleJson {
                height: 4
                width: 26
                color: Colors.color.primary
                rounding {
                    topLeft: 100
                    topRight: 100
                    bottomLeft: 100
                    bottomRight: 100
                }
            }
        }
        property RectangleJson handle: RectangleJson {
            color: Colors.color.primary
            height: 26
            width: 26
            rounding {
                topLeft: 13
                topRight: 13
                bottomLeft: 13
                bottomRight: 13
            }
        }
    }

    component Label: JsonObject {
        property color text: Colors.color.primary
        property RectangleJson background: RectangleJson {}
    }

    component Range: JsonObject {
        property RectangleJson background: RectangleJson {
            width: 200
            height: 4

            rounding {
                topLeft: 0
                topRight: 0
                bottomRight: 0
                bottomLeft: 0
            }
            color: Colors.color.primary
            property RectangleJson indicator: RectangleJson {
                color: Colors.color.tertiary
            }
        }
        property RectangleJson first: RectangleJson {
            height: 26
            width: 26
            color: Colors.color.primary
            border {
                width: 1
                color: Colors.color.outline
            }
            rounding {
                topLeft: 13
                topRight: 13
                bottomRight: 13
                bottomLeft: 13
            }
        }
        property RectangleJson second: RectangleJson {
            height: 26
            width: 26
            color: Colors.color.primary
            border {
                width: 1
                color: Colors.color.outline
            }
            rounding {
                topLeft: 13
                topRight: 13
                bottomRight: 13
                bottomLeft: 13
            }
        }
    }

    IpcHandler {
        target: "config"
        function toggleWallpaperPicker() {
        }

        function toggleAppLauncher() {
        }

        function toggleSessionMenu() {
        }

        function toggleExtendedBar() {
        }

        function toggleSettingsPanel() {
            config.enableSetting = !config.enableSetting;
        }
    }
}
