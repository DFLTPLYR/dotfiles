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
    readonly property var path: Wallpaper.config.source.filter(s => s && s.monitor === screen.name) || []
    property bool edit: false
    property bool fileExplorerOpen: false
    color: "transparent"
    signal dockUpdate(var data)

    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: {
        if (!Global.edit)
            return WlrLayer.Background;
        if ((wallpaperModal.opened || propertiesModal.opened) && !fileExplorerOpen)
            return WlrLayer.Top;
        return WlrLayer.Bottom;
    }
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: `Background-${screen.name}`

    mask: Region {
        item: mask
    }

    Item {
        id: layered
        width: parent.width
        height: parent.width

        Instantiator {
            model: ScriptModel {
                values: [...Wallpaper.config.layers].filter(item => item && item.screens && item.screens.some(s => s && s.name === panel.screen.name))
            }
            delegate: Image {
                id: wallpaperImage
                required property var modelData
                property var relative: modelData.screens.find(s => s && s.name === panel.screen.name)
                parent: layered

                width: modelData.width
                height: modelData.height
                x: relative.x
                y: relative.y

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

    Loader {
        id: mask
        anchors.fill: parent
        active: Global.edit
        sourceComponent: MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                switch (mouse.button) {
                case Qt.RightButton:
                    if (!contextMenu.opened) {
                        contextMenu.x = mouseX + contextMenu.width > screen.width ? mouseX - contextMenu.width : mouseX;
                        contextMenu.y = mouseY + contextMenu.height > screen.height ? mouseY - contextMenu.height : mouseY;
                    }
                    contextMenu.opened ? contextMenu.close() : contextMenu.open();
                    return;
                case Qt.LeftButton:
                    if (contextMenu.opened)
                        contextMenu.close();
                    return;
                default:
                    return;
                }
            }
        }
    }

    FilePicker {
        id: fileExplorer
        onOutput: data => {
            if (data) {
                var image = {
                    source: data.trim("%0A"),
                    name: Math.random().toString(36).substring(2, 10)
                };
                Wallpaper.config.layers.push(image);
                Wallpaper.save();
            }
            panel.fileExplorerOpen = false;
        }
    }

    // simple desktop popup
    ContextMenu {
        id: contextMenu
        onAction: action => {
            switch (action) {
            case "property":
                propertiesModal.visible = true;
                contextMenu.close();
                break;
            case "wallpaper":
                wallpaperModal.visible = true;
                contextMenu.close();
                break;
            default:
                break;
            }
        }
    }

    // Properties Modal
    PropertyMenu {
        id: propertiesModal
        screen: panel.screen
    }

    // Wallpaper Modal
    WallpaperMenu {
        id: wallpaperModal
        screen: panel.screen
    }

    function onSaveCustomWallpaper() {
        layered.grabToImage(function (result) {
            result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);
            Qt.callLater(() => {
                Global.updateColor();
            });
        }, Qt.size(panel.screen.width, panel.screen.height));
    }
}
