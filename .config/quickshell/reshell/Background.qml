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

    signal dockUpdate(var data)

    color: "transparent"
    implicitHeight: screen.height
    implicitWidth: screen.width

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: `Background-${screen.name}`
    WlrLayershell.layer: {
        if (!Global.edit)
            return WlrLayer.Background;
        if ((wallpaperModal.opened || propertiesModal.opened) && !fileExplorerOpen)
            return WlrLayer.Top;
        return WlrLayer.Bottom;
    }

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

    Rectangle {
        id: selectionRect
        x: 0
        y: 0
        z: 99
        visible: false
        width: 0
        height: 0
        rotation: 0
        color: Colors.setOpacity(Colors.color.primary, 0.5)
        border.width: 1
        border.color: Colors.color.tertiary
        transformOrigin: Item.TopLeft
    }

    MouseArea {
        id: selectionMouseArea
        property point startPoint
        property bool selecting
        anchors.fill: parent
        z: 2

        onPressed: mouse => {
            if (mouse.button == Qt.LeftButton && mouse.modifiers & Qt.ShiftModifier) {
                selecting = true;
                startPoint = Qt.point(mouse.x, mouse.y);
                selectionRect.x = mouse.x;
                selectionRect.y = mouse.y;
                selectionRect.width = 0;
                selectionRect.height = 0;
                selectionRect.visible = true;
            }
        }

        onPositionChanged: mouse => {
            if (selecting) {
                var minX = Math.min(startPoint.x, mouse.x);
                var minY = Math.min(startPoint.y, mouse.y);
                var maxX = Math.max(startPoint.x, mouse.x);
                var maxY = Math.max(startPoint.y, mouse.y);

                selectionRect.x = minX;
                selectionRect.y = minY;
                selectionRect.width = maxX - minX;
                selectionRect.height = maxY - minY;
            }
        }

        onReleased: {
            selecting = false;
            selectionRect.visible = false;
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
