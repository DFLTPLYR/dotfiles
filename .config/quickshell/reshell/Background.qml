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
    property Item area: null
    readonly property var images: Wallpaper.config.preset.find(s => s.name === Wallpaper.config.current)
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
        item: panel.area
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

    // MouseArea
    LazyLoader {
        active: Global.edit
        component: MouseArea {
            parent: layered
            width: screen.width
            height: screen.height
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property bool selecting
            property point startPoint

            onPressed: mouse => {
                if (mouse.button == Qt.LeftButton && mouse.modifiers & Qt.ShiftModifier) {
                    selecting = true;
                    startPoint = Qt.point(mouse.x, mouse.y);
                    selectionRect.x = mouse.x;
                    selectionRect.y = mouse.y;
                    selectionRect.width = 0;
                    selectionRect.height = 0;
                    selectionRect.visible = true;
                } else if (mouse.button === Qt.RightButton) {
                    if (!contextMenu.opened) {
                        contextMenu.x = mouseX + contextMenu.width > screen.width ? mouseX - contextMenu.width : mouseX;
                        contextMenu.y = mouseY + contextMenu.height > screen.height ? mouseY - contextMenu.height : mouseY;
                    }
                    contextMenu.opened ? contextMenu.close() : contextMenu.open();
                    return;
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

            onReleased: mouse => {
                if (mouse.button == Qt.LeftButton && mouse.modifiers & Qt.ShiftModifier) {
                    selecting = false;
                    selectionRect.visible = false;
                    const container = {
                        w: selectionRect.width,
                        h: selectionRect.height,
                        x: selectionRect.x,
                        y: selectionRect.y,
                        z: 1
                    };

                    layered.containers.push(container);
                }
            }

            Component.onCompleted: {
                panel.area = this;
            }
        }
    }

    // selectionRect
    Rectangle {
        id: selectionRect
        x: 0
        y: 0
        z: 9999
        visible: false
        width: 0
        height: 0
        rotation: 0
        color: Colors.setOpacity(Colors.color.primary, 0.5)
        border.width: 1
        border.color: Colors.color.tertiary
        transformOrigin: Item.TopLeft
    }

    // Contents
    Item {
        id: layered
        property list<var> containers: []
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

        Instantiator {
            model: [...layered.containers]
            delegate: ResizeableRect {
                required property var modelData
                pointerVisible: true
                parent: layered
                width: modelData.w
                height: modelData.h
                x: modelData.x
                y: modelData.y
                z: modelData.z
                color: Colors.setOpacity(Colors.color.primary, 0.4)

                DragHandler {
                    id: dragHandler
                    target: parent
                }

                WheelHandler {
                    id: wheelHandler
                    enabled: true
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    target: null

                    onWheel: event => {
                        let isShiftWheel = event.modifiers & Qt.ShiftModifier;
                        if (isShiftWheel && wheelHandler.enabled) {
                            if (event.angleDelta.y > 0) {
                                parent.z++;
                            } else {
                                parent.z--;
                            }
                            print(parent.z);
                        }
                    }
                }
            }
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
            case "fileExplorer":
                panel.fileExplorerOpen = true;
                break;
            default:
                break;
            }
        }
    }

    FileExplorer {
        screen: panel.screen
        visible: panel.fileExplorerOpen
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
