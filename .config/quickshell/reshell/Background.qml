import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtCore

import qs.core
import qs.modules
import qs.components

PanelWindow {
    id: panel
    property var file
    readonly property var images: Wallpaper.config.preset.find(s => s.name === Wallpaper.config.current)
    readonly property var path: Wallpaper.config.source.filter(s => s && s.monitor === screen.name) || []
    property bool edit: false
    property bool fileExplorerOpen: false

    color: "transparent"
    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: `Background-${screen.name}`
    WlrLayershell.layer: WlrLayer.Background

    // Contents
    Item {
        id: layered
        width: parent.width
        height: parent.width

        property ListModel wallpaper: ListModel {
            id: wallpaperModel

            function sync() {
                wallpaperModel.clear();
                const current = Wallpaper.config.current;
                const theme = Wallpaper.config.preset.find(s => s.name === current);
                const sources = theme.source;
                const container = sources.filter(item => item && item.screens && item.screens.some(s => s && s.name === panel.screen.name));
                for (const i in container) {
                    const obj = container[i];
                    wallpaperModel.append(obj);
                }
            }

            Component.onCompleted: this.sync()
        }

        Instantiator {
            model: wallpaperModel
            delegate: Image {
                id: wallpaperImage
                required property var modelData
                property var relative: modelData.screens
                property var coords
                onRelativeChanged: {
                    for (let i = 0; i < relative.count; i++) {
                        const screen = relative.get(i);
                        if (screen.name === panel.screen.name) {
                            return coords = screen;
                        }
                    }
                }

                parent: layered

                width: modelData.width
                height: modelData.height

                x: coords.x
                y: coords.y
                z: modelData.z

                source: modelData.source
                opacity: 0

                states: State {
                    name: "visible"
                    PropertyChanges {
                        target: wallpaperImage
                        opacity: 1
                    }
                }

                transitions: [
                    Transition {
                        from: "*"
                        to: "*"
                        NumberAnimation {
                            properties: "opacity,scale"
                            duration: 300
                            easing.type: Easing.InOutSine
                        }
                    }
                ]
            }
            onObjectAdded: (idx, obj) => obj.state = "visible"
        }
    }

    Connections {
        target: Wallpaper
        function onGeneratecolor() {
            wallpaperModel.sync();
            Qt.callLater(() => {
                layered.grabToImage(function (result) {
                    result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);
                    Qt.callLater(() => {
                        Global.updateColor();
                    });
                }, Qt.size(panel.screen.width, panel.screen.height));
            });
        }
    }
}
