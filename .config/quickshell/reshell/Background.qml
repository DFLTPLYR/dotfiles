import QtQml.Models
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
    property bool edit: false
    property bool fileExplorerOpen: false

    color: "transparent"
    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: `Background-${screen.name}`
    WlrLayershell.layer: WlrLayer.Background

    DelegateModel {
        id: images
        property bool setup: true
        model: Wallpaper.list
        filterOnGroup: images.setup ? "list" : panel.screen.name.toLowerCase()
        groups: [
            DelegateModelGroup {
                name: "list"
                includeByDefault: true
            },
            DelegateModelGroup {
                name: panel.screen.name.toLowerCase()
                includeByDefault: false
            }
        ]
        onCountChanged: setGroups(model.count)

        function setGroups() {
            if (items.count <= 0)
                return;
            for (let i = 0; i < items.count; i++) {
                const item = items.get(i);
                const modelData = item.model;

                if (modelData && modelData.screens) {
                    const screenArr = modelData.screens;
                    const screens = ["list"]; // Start with default group

                    for (let j = 0; j < screenArr.count; j++) {
                        const screenObj = screenArr.get(j);
                        screens.push(screenObj.name.toLowerCase());
                    }

                    items.setGroups(i, 1, screens);
                }
            }
        }

        delegate: Item {
            id: container
            required property var model
            required property int index
            required property string source
            required property ListModel screens
            property var relativePos: findMatchingScreen()
            function findMatchingScreen() {
                if (!screens || !panel || !panel.screen || screens.count === 0) {
                    return null;
                }

                const targetName = panel.screen.name.toLowerCase();

                for (let i = 0; i < screens.count; i++) {
                    const config = screens.get(i);
                    if (config && config.name && config.name.toLowerCase() === targetName) {
                        return config;
                    }
                }
                return null;
            }
            width: image.width
            height: image.height
            x: image.x
            y: image.y
            z: model.z

            Image {
                id: image
                width: container.model.width
                height: container.model.height
                source: container.model.source
                x: container.relativePos ? container.relativePos.x : 0
                y: container.relativePos ? container.relativePos.y : 0
            }
        }

        Component.onCompleted: images.setGroups(model.count)
    }

    Connections {
        target: Wallpaper.list
        function onUpdate(idx) {
            images.setGroups(model.count);
        }
    }

    ListView {
        id: layered
        interactive: false
        width: parent.width
        height: parent.width
        snapMode: ListView.NoSnap
        model: images
        Component.onCompleted: model.setup = false
    }

    // Contents
    // Item {
    //     id: layered
    //     width: parent.width
    //     height: parent.width
    //
    //     property ListModel wallpaper: ListModel {
    //         id: wallpaperModel
    //
    //         function sync() {
    //             wallpaperModel.clear();
    //             const current = Wallpaper.config.current;
    //             const theme = Wallpaper.config.preset.find(s => s.name === current);
    //             const sources = theme.source;
    //             const container = sources.filter(item => item && item.screens && item.screens.some(s => s && s.name === panel.screen.name));
    //             for (const i in container) {
    //                 const obj = container[i];
    //                 wallpaperModel.append(obj);
    //             }
    //         }
    //
    //         Component.onCompleted: this.sync()
    //     }
    //
    //     Instantiator {
    //         model: wallpaperModel
    //         delegate: Image {
    //             id: wallpaperImage
    //             required property var modelData
    //             property var relative: modelData.screens
    //             property var coords
    //             onRelativeChanged: {
    //                 for (let i = 0; i < relative.count; i++) {
    //                     const screen = relative.get(i);
    //                     if (screen.name === panel.screen.name) {
    //                         return coords = screen;
    //                     }
    //                 }
    //             }
    //
    //             parent: layered
    //
    //             width: modelData.width
    //             height: modelData.height
    //
    //             x: coords.x
    //             y: coords.y
    //             z: modelData.z
    //
    //             source: modelData.source
    //             opacity: 0
    //
    //             states: State {
    //                 name: "visible"
    //                 PropertyChanges {
    //                     target: wallpaperImage
    //                     opacity: 1
    //                 }
    //             }
    //
    //             transitions: [
    //                 Transition {
    //                     from: "*"
    //                     to: "*"
    //                     NumberAnimation {
    //                         properties: "opacity,scale"
    //                         duration: 300
    //                         easing.type: Easing.InOutSine
    //                     }
    //                 }
    //             ]
    //         }
    //         onObjectAdded: (idx, obj) => obj.state = "visible"
    //     }
    // }

    Connections {
        target: Wallpaper
        function onGeneratecolor() {
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
