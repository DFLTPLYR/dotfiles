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
    property var file
    property bool edit: false
    signal dockUpdate(var data)
    signal save

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Control) {}
    }

    Keys.onReleased: event => {
        if (event.key === Qt.Key_Control) {}
    }

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
                                    const conf = Background.containers.get(containerloader.index);
                                    const withProps = conf.contents;
                                    withProps.props = props;
                                    Background.containers.setProperty(containerloader.index, "contents", withProps);
                                    Background.containers.save();
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
            model: Background.containers
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
                propagateComposedEvents: true
                onPressed: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    if (contextMenu.opened)
                        contextMenu.close();
                    Background.contextArea.selecting = true;
                    Background.contextArea.startPoint = mapToGlobal(mouse.x, mouse.y);
                    Background.contextArea.x = Background.contextArea.startPoint.x;
                    Background.contextArea.y = Background.contextArea.startPoint.y;
                }

                onPositionChanged: mouse => {
                    const idx = Background.contextIdx;
                    if (idx < 0)
                        return;
                    const sp = Background.contextArea.startPoint;
                    const gp = mapToGlobal(mouse.x, mouse.y);
                    var minX = Math.min(sp.x, gp.x);
                    var minY = Math.min(sp.y, gp.y);
                    var maxX = Math.max(sp.x, gp.x);
                    var maxY = Math.max(sp.y, gp.y);
                    Background.contextArea.x = minX;
                    Background.contextArea.y = minY;
                    Background.contextArea.width = maxX - minX;
                    Background.contextArea.height = maxY - minY;
                }

                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    Background.contextArea.selecting = false;
                }
            }
        }

        // selectionRect
        Rectangle {
            id: selectionRect
            property bool intersect: Background.contextArea.width > 0 && Background.contextArea.height > 0 && intersects(Background.contextArea, panel.screen)

            opacity: Background.contextArea.selecting && intersect ? 1 : 0
            width: Math.min(Background.contextArea.x + Background.contextArea.width, panel.screen.x + panel.screen.width) - Math.max(Background.contextArea.x, panel.screen.x)
            height: Math.min(Background.contextArea.y + Background.contextArea.height, panel.screen.y + panel.screen.height) - Math.max(Background.contextArea.y, panel.screen.y)
            x: Math.max(Background.contextArea.x, panel.screen.x) - panel.screen.x
            y: Math.max(Background.contextArea.y, panel.screen.y) - panel.screen.y
            z: 9999
            color: Colors.setOpacity(Colors.theme.tertiary, 0.5)
            border.width: 1
            border.color: Colors.theme.outline
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
            target: Background.containers
            function onGenerate() {
                const screen = layered.grabToImage(function (result) {
                    result.saveToFile(`${StandardPaths.writableLocation(StandardPaths.CacheLocation)}/cropped_${panel.screen.name}.jpg`);

                    const exist = Global.readyBg.find(panel.screen.name);
                    Global.readyBg = [...Global.readyBg, panel.screen.name];
                }, Qt.size(background.screen.width, background.screen.height));
            }
        }
    }

    function intersects(a, b) {
        return !(a.x + a.width < b.x || a.x > b.x + b.width || a.y + a.height < b.y || a.y > b.y + b.height);
    }
}
