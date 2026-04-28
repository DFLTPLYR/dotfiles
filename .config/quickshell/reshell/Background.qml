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

            Component.onCompleted: {
                const container = Wallpaper.config.layers.filter(item => item && item.screens && item.screens.some(s => s && s.name === panel.screen.name));
                for (const i in container) {
                    const obj = container[i];
                    wallpaperModel.append(obj);
                }
            }
        }

        // Causes Crash as of now
        // SortFilterProxyModel {
        //     id: wallpaperSort
        //     model: Wallpaper.list
        //     filters: [
        //         FunctionFilter {
        //             function filter(data: RoleData): bool {
        //                 for (let i = 0; i < data.screens.count; i++) {
        //                     const screen = data.screens.get(i);
        //                     if (screen.name === panel.screen.name) {
        //                         return true;
        //                     }
        //                 }
        //                 return false;
        //             }
        //         }
        //     ]
        // }

        Instantiator {
            model: wallpaperModel
            delegate: Image {
                id: wallpaperImage
                required property var modelData
                parent: layered

                width: modelData.width
                height: modelData.height

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

    // component RoleData: QtObject {
    //     property string name
    //     property ListModel screens
    //     property string source
    //     property real height
    //     property real width
    //     property real x
    //     property real y
    //     property real z
    // }

    function onSaveCustomWallpaper() {
        layered.grabToImage(function (result) {
            result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);
            Qt.callLater(() => {
                Global.updateColor();
            });
        }, Qt.size(panel.screen.width, panel.screen.height));
    }
}
