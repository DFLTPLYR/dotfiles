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
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    if (contextMenu.opened)
                        contextMenu.close();
                    selecting = true;
                    startPoint = mapToGlobal(mouse.x, mouse.y);
                    const obj = {
                        x: mouse.x,
                        y: mouse.y,
                        z: 999999,
                        screens: [],
                        width: 0,
                        height: 0,
                        contents: {
                            type: "selection"
                        }
                    };
                    Wallpaper.containers.append(obj);
                    Wallpaper.contextIdx = Wallpaper.containers.count - 1;
                }

                onPositionChanged: mouse => {
                    if (!selecting)
                        return;
                    const idx = Wallpaper.contextIdx;
                    if (idx < 0)
                        return;

                    const gp = mapToGlobal(mouse.x, mouse.y);
                    var minX = Math.min(startPoint.x, gp.x);
                    var minY = Math.min(startPoint.y, gp.y);
                    var maxX = Math.max(startPoint.x, gp.x);
                    var maxY = Math.max(startPoint.y, gp.y);

                    const rect = {
                        x: minX,
                        y: minY,
                        width: maxX - minX,
                        height: maxY - minY
                    };

                    const screens = overlapsAny(rect);
                    const c = Wallpaper.containers;
                    c.setProperty(idx, "x", minX);
                    c.setProperty(idx, "y", minY);
                    c.setProperty(idx, "width", maxX - minX);
                    c.setProperty(idx, "height", maxY - minY);
                    c.setProperty(idx, "screens", screens);
                }

                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    selecting = false;
                    Wallpaper.containers.remove(Wallpaper.contextIdx, 1);
                    Wallpaper.contextArea = null;
                    Wallpaper.contextIdx = -1;
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
            opacity: Wallpaper.contextArea ? 1 : 0
            // width: Wallpaper.contextArea.width
            // height: Wallpaper.contextArea.height
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
        for (let i = 0; i < screens.length; i++) {
            const screen = screens[i];

            if (intersects(target, screen)) {
                newScreens.push(getRelativePos(target, screen));
            }
        }
        return newScreens;
    }

    function intersects(a, b) {
        return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
    }

    function getRelativePos(target, screen) {
        var relative = {
            x: target.x - screen.x,
            y: target.y - screen.y,
            name: screen.objectName
        };
        return relative;
    }
}
