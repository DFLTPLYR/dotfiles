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

    component LazyImage: LazyLoader {
        id: imageloader
        required property int index
        required property var model
        property var relative: model.screens
        property var coords

        active: coords
        onRelativeChanged: {
            if (!relative || !relative.count)
                return;
            for (let i = 0; i < relative.count; i++) {
                const screen = relative.get(i);
                if (screen.name === panel.screen.name) {
                    return coords = screen;
                }
            }
        }

        component: Image {
            parent: layered

            width: imageloader.model.width
            height: imageloader.model.height
            visible: imageloader.coords ? true : false
            x: imageloader.coords ? imageloader.coords.x : 0
            y: imageloader.coords ? imageloader.coords.y : 0
            z: imageloader.model.z

            source: imageloader.model.source
        }
    }

    color: "transparent"
    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: `Background-${screen.name}`
    WlrLayershell.layer: WlrLayer.Background

    DelegateModel {
        id: images
        model: Wallpaper.list
        delegate: LazyImage {}
    }

    Item {
        id: layered
        anchors.fill: parent
        Instantiator {
            model: images
            onObjectRemoved: (idx, obj) => {
                obj.destroy();
            }
        }
    }

    Connections {
        target: Wallpaper.list
        function onGenerate() {
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
