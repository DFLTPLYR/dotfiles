pragma ComponentBehavior: Bound
pragma Singleton
import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io
import System

Singleton {
    id: config
    signal generate

    property Component contentDelegate: Component {
        DelegateChooser {
            id: chooser
            role: "type"
            required property ShellScreen panel
            DelegateChoice {
                roleValue: "image/gif"
                AnimatedImage {}
            }
            DelegateChoice {
                roleValue: "image/jpeg"
                WallpaperImage {
                    screen: chooser.panel
                }
            }
            DelegateChoice {
                roleValue: "image/jpg"
                WallpaperImage {
                    screen: chooser.panel
                }
            }
            DelegateChoice {
                roleValue: "image/png"
                WallpaperImage {
                    screen: chooser.panel
                }
            }
        }
    }

    component WallpaperImage: Image {
        required property var modelData
        required property ShellScreen screen
        property bool intersect: modelData.width > 0 && modelData.height > 0 && Utils.intersects(modelData, screen)
        width: {
            if (modelData.width === 0) {
                return sourceSize.width;
            }
            return modelData.width;
        }
        height: {
            if (modelData.height === 0) {
                return sourceSize.height;
            }
            return modelData.height;
        }

        source: modelData.path

        x: modelData.x - screen.x
        y: modelData.y - screen.y
        z: modelData.z
        scale: modelData.scale
        smooth: true
        mipmap: true
        asynchronous: true
    }

    component Container: QtObject {
        property int x: 0
        property int y: 0
        property int z: 0
        property int width: 0
        property int height: 0
        property string path: ""
    }

    property Component widgetContainerFactory: Component {
        Container {
            property var property: null
            property var config: ({})
            onConfigChanged: {
                if (typeof this.config !== "object" || !this.config)
                    return;
                const val = Utils.getProperty(this.config);
                if (Object.keys(val).length)
                    setUp(val);
            }

            function setUp(data) {
                const obj = Widgets.createObject();
                for (let i in data) {
                    const value = data[i];
                    Widgets.setProperty(obj, i, value);
                }
                return this.property = obj;
            }

            function bindProperty(obj) {
                const prop = Utils.getProperty(property);
                for (let i in prop) {
                    obj[i] = Qt.binding(() => {
                        return property[i];
                    });
                }
            }
        }
    }
    property Component imageContainerFactory: Component {
        Container {
            property string type: ""
            property int scale: 1
        }
    }

    property bool ready: false
    property bool enableSetting: false
    property alias config: jsonadapter.config
    property QtObject selectionRect: QtObject {
        property point startPoint
        property bool selecting: false
        // onSelectingChanged: {
        //     if (selecting)
        //         return;
        //     if (width >= 50 && height >= 50) {
        //         const box = widgetContainerFactory.createObject(null, {
        //             x,
        //             y,
        //             width,
        //             height,
        //             z: 0
        //         });
        //         config.widgetArr = [...config.widgetArr, box];
        //     }
        //     width = 0;
        //     height = 0;
        //     x = 0;
        //     y = 0;
        // }
        property int width: 0
        property int height: 0
        property int x: 0
        property int y: 0
    }

    property var widgetArr: []
    property var wallpaperArr: []

    FileView {
        id: fileView
        path: Qt.resolvedUrl("data/background.json")
        watchChanges: true
        preload: true
        onLoaded: {
            Background.wallpaperArr = [];
            Background.widgetArr = [];
            const current = jsonadapter.config.current;
            const theme = jsonadapter.config.preset.find(s => s.name === current);
            const wallpapers = theme?.wallpapers;
            const widgets = theme?.widgets;
            for (let i in wallpapers) {
                const wp = wallpapers[i];
                const img = imageContainerFactory.createObject(null, {
                    path: wp.path,
                    type: wp.type,
                    width: wp.width,
                    height: wp.height,
                    x: wp.x,
                    y: wp.y,
                    z: wp.z
                });
                Background.wallpaperArr = [...Background.wallpaperArr, img];
            }
            for (let i in widgets) {
                const wp = widgets[i];
                const wdg = widgetContainerFactory.createObject(null, {
                    width: wp.width,
                    height: wp.height,
                    x: wp.x,
                    y: wp.y,
                    z: wp.z,
                    path: wp.path,
                    config: wp.config || {}
                });
                Background.widgetArr = [...Background.widgetArr, wdg];
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
            id: jsonadapter
            property JsonObject config: JsonObject {
                property string current: "default"
                property list<var> preset: [
                    {
                        name: "default",
                        wallpapers: [],
                        widgets: []
                    }
                ]
                property string theme: "scheme-content"
                onThemeChanged: {
                    config.generate();
                }
            }
        }
    }

    function save() {
        const current = jsonadapter.config.current;
        const preset = jsonadapter.config.preset;
        const themeIdx = preset.findIndex(s => s.name === current);
        if (themeIdx === -1)
            return;

        const wpArr = [];
        const wdgArr = [];
        for (let i in config.wallpaperArr) {
            const image = config.wallpaperArr[i];
            const keys = Utils.getProperty(image);
            wpArr.push(keys);
        }
        for (let i in config.widgetArr) {
            const wdg = config.widgetArr[i];
            const keys = Utils.getProperty(wdg, ["instance", "property"]);
            const props = Utils.getProperty(wdg.property);
            if (Object.keys(props).length)
                keys.config = props;
            wdgArr.push(keys);
        }
        jsonadapter.config.preset[themeIdx].widgets = wdgArr;
        jsonadapter.config.preset[themeIdx].wallpapers = wpArr;
        fileView.writeAdapter();
    }
}
