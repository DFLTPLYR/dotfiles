pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtCore

import qs.core
import qs.modules
import qs.components

Item {
    id: panel
    property ShellScreen screen
    property Item area: null
    property var file
    property bool edit: false
    signal dockUpdate(var data)
    signal save

    component LazyContainer: LazyLoader {
        id: containerloader
        required property int index
        required property var model
        property var relative: model.screens
        property var coords
        property var contents: model.contents
        property var currentContent
        onContentsChanged: {
            if (!contents || !item)
                return;
            return addContent();
        }
        onItemChanged: {
            if (!contents || !item)
                return;
            return addContent();
        }

        function addContent() {
            const type = contents.type;

            if (containerloader.currentContent) {
                containerloader.currentContent.destroy();
            }
            switch (type) {
            case "image":
                item.parent = layered;
                const img = Components.createImage(contents.source, contents.kind, item);
                containerloader.currentContent = img;
                return;
            case "widget":
                item.parent = Qt.binding(() => {
                    return Global.widget ? controlArea : layered;
                });
                const component = Qt.createComponent(contents.source);
                const incubator = component.incubateObject(containerloader.item, {});
                if (incubator && incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function (status) {
                        if (status === Component.Ready) {
                            const widget = incubator.object;
                            widget.parent = containerloader.item;
                            widget.anchors.fill = containerloader.item;
                            containerloader.currentContent = widget;
                            if (contents.props) {
                                widget.property.setProperty(contents.props);
                            }
                            widget.modal.connect((modal, hasChanges) => {
                                bottom.hasMenu = modal ? true : false;
                                if (modal) {
                                    modal.y = item.height;
                                    modal.x = (item.width - modal.width) / 2;
                                }
                                if (hasChanges) {
                                    const props = widget.property.getProperty();
                                    const conf = Wallpaper.containers.get(containerloader.index);
                                    const withProps = conf.contents;
                                    withProps.props = props;
                                    Wallpaper.containers.setProperty(containerloader.index, "contents", withProps);
                                    Wallpaper.containers.save();
                                }
                            });
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
            bg.color: "transparent"
            width: containerloader.model.width
            height: containerloader.model.height
            visible: containerloader.coords ? true : false
            x: containerloader.coords ? containerloader.coords.x : 0
            y: containerloader.coords ? containerloader.coords.y : 0
            z: containerloader.model.z
        }
    }

    DelegateModel {
        id: containers
        model: Wallpaper.containers
        delegate: LazyContainer {}
    }

    Instantiator {
        model: containers
    }

    // background
    PanelWindow {
        id: background
        screen: panel.screen
        mask: Region {
            item: layered
        }
        color: "transparent"
        implicitHeight: screen.height
        implicitWidth: screen.width

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: `Background-${screen.name}`
        WlrLayershell.layer: WlrLayer.Background

        Item {
            id: layered
            anchors.fill: parent
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
                    }, Qt.size(background.screen.width, background.screen.height));
                });
            }
        }
    }

    // bottom
    PanelWindow {
        id: bottom
        property bool hasMenu: false
        screen: panel.screen

        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.keyboardFocus: bottom.hasMenu ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        WlrLayershell.namespace: `Bottom-${screen.name}`
        WlrLayershell.layer: WlrLayer.Bottom

        mask: Region {
            item: controlArea
        }

        Item {
            id: controlArea
            width: parent.width
            height: parent.height

            MouseArea {
                z: -999999
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                property bool selecting
                property point startPoint
                onPressed: mouse => {
                    if (mouse.button == Qt.LeftButton) {
                        if (contextMenu.opened)
                            contextMenu.close();
                        selecting = true;
                        startPoint = Qt.point(mouse.x, mouse.y);
                        selectionRect.x = mouse.x;
                        selectionRect.y = mouse.y;
                        selectionRect.width = 0;
                        selectionRect.height = 0;
                        selectionRect.opacity = 1;
                    } else if (mouse.button === Qt.RightButton) {
                        contextMenu.x = mouseX;
                        contextMenu.y = mouseY;
                        contextMenu.open();
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
                    if (mouse.button == Qt.LeftButton) {
                        selecting = false;
                        selectionRect.opacity = 0;

                        if (selectionRect.x == 0 && selectionRect.y == 0)
                            return;
                        const container = {
                            w: selectionRect.width,
                            h: selectionRect.height,
                            x: selectionRect.x,
                            y: selectionRect.y,
                            z: 1,
                            content: []
                        };
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
            opacity: 0
            width: 0
            height: 0
            rotation: 0
            color: Colors.setOpacity(Colors.theme.tertiary, 0.5)
            border.width: 1
            border.color: Colors.theme.outline
            transformOrigin: Item.TopLeft

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        // simple desktop popup
        ContextMenu {
            id: contextMenu
            screen: panel.screen
            x: (screen.width - width) / 2
            y: (screen.height - height) / 2
        }
    }
}
