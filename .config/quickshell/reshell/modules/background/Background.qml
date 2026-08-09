pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick

import Quickshell
import Quickshell.Wayland

import qs.core
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
                item.parent = controlArea;
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
            bg.border.color: Global.widget ? Colors.theme.primary : "transparent"
            bg.border.width: Global.widget ? 2 : 0
            width: containerloader.model.width
            height: containerloader.model.height
            visible: containerloader.coords ? true : false
            x: containerloader.coords ? containerloader.coords.x : 0
            y: containerloader.coords ? containerloader.coords.y : 0
            z: containerloader.model.z
        }
    }

    Instantiator {
        model: DelegateModel {
            model: Wallpaper.containers
            delegate: LazyContainer {}
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
        WlrLayershell.namespace: `Background-${screen.name}`
        WlrLayershell.layer: WlrLayer.Bottom

        mask: Region {
            item: controlArea
        }

        Item {
            id: layered
            anchors.fill: parent
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
                        // selectionRect.x = mouse.x;
                        // selectionRect.y = mouse.y;
                        // selectionRect.width = 0;
                        // selectionRect.height = 0;
                        // selectionRect.opacity = 1;
                        const obj = {
                            x: mouse.x,
                            y: mouse.y,
                            z: 999999,
                            screens: [panel.screen.name],
                            width: 0,
                            height: 0,
                            contents: {
                                type: "selection"
                            }
                        };
                        Wallpaper.containers.append(obj);
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

                        Wallpaper.contextArea.width = maxX - minX;
                    }
                }

                onReleased: mouse => {
                    if (mouse.button == Qt.LeftButton) {
                        selecting = false;
                        selectionRect.opacity = 0;

                        if (selectionRect.x == 0 && selectionRect.y == 0)
                            return;
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
            onOpacityChanged: {
                // Wallpaper.containers.set(containerRect.index, obj);
            }
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

        // Contents
        Connections {
            target: Wallpaper.containers
            function onGenerate() {
                const screen = layered.grabToImage(function (result) {
                    result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);

                    const exist = Global.readyBg.find(panel.screen.name);
                    Global.readyBg = [...Global.readyBg, panel.screen.name];
                }, Qt.size(background.screen.width, background.screen.height));
            }
        }
    }

    function overlapsAny(target) {
        const screens = Quickshell.screens;
        const newScreens = [];
        const origin = target.mapToGlobal(0, 0);

        const globalRect = {
            x: origin.x,
            y: origin.y,
            width: target.width,
            height: target.height
        };

        for (let i = 0; i < screens.length; i++) {
            const screen = screens[i];

            if (intersects(globalRect, screen)) {
                newScreens.push(getRelativePos(globalRect, screen));
            }
        }
        return newScreens;
    }

    function intersects(a, b) {
        return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
    }

    function getRelativePos(target, screen) {
        const x = Math.max(target.x, screen.x);
        const y = Math.max(target.y, screen.y);
        const right = Math.min(target.x + target.width, screen.x + screen.width);
        const bottom = Math.min(target.y + target.height, screen.y + screen.height);

        return {
            x: x - screen.x,
            y: y - screen.y,
            width: right - x,
            height: bottom - y,
            name: screen.objectName
        };
    }
}
