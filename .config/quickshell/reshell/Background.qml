pragma ComponentBehavior: Bound

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

    Component {
        id: imageObject
        Image {
            anchors.fill: parent
        }
    }

    Component {
        id: widgets
        LazyLoader {
            property var parent
            active: source
            onItemChanged: {
                if (!item)
                    return;
                item.source = parent;
            }
        }
    }

    component LazyContainer: LazyLoader {
        id: containerloader
        required property int index
        required property var model
        property var relative: model.screens
        property var coords
        property var contents: model.contents
        property var currentContent
        onContentsChanged: addContent()
        onItemChanged: {
            if (!contents || !item)
                return;
            addContent();
        }

        function addContent() {
            const type = contents.type;

            if (containerloader.currentContent) {
                containerloader.currentContent.destroy();
            }
            switch (type) {
            case "image":
                const image = imageObject.createObject(item, {
                    source: contents.source
                });
                containerloader.currentContent = image;
                return;
            case "widget":
                const component = Qt.createComponent(contents.source);
                const incubator = component.incubateObject(containerloader.item, {});
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function (status) {
                        if (status === Component.Ready) {
                            const widget = incubator.object;
                            widget.parent = containerloader.item;
                            widget.anchors.fill = containerloader.item;
                            containerloader.currentContent = widget;
                        }
                    };
                }
                return;
            default:
                return;
            }
        }

        active: coords || false
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

        component: Pane {
            parent: layered

            width: containerloader.model.width
            height: containerloader.model.height
            visible: containerloader.coords ? true : false
            x: containerloader.coords ? containerloader.coords.x : 0
            y: containerloader.coords ? containerloader.coords.y : 0
            z: containerloader.model.z
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
        id: containers
        model: Wallpaper.containers
        delegate: LazyContainer {}
    }

    Item {
        id: layered
        anchors.fill: parent

        Instantiator {
            model: containers
        }
    }

    Connections {
        target: Wallpaper.containers
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
