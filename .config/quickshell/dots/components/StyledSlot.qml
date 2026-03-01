import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.config

Rectangle {
    id: slotRoot
    signal slotDestroyed(var widgets)
    property list<Item> widgets: []
    property alias background: backgroundRect
    property bool hasPanel: false

    color: "transparent"
    border.color: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on border.color {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    default property alias content: childHandler.data
    property string position: "left"

    onChildrenChanged: {
        Qt.callLater(() => {
            const copy = children ? children.slice() : [];
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (slotLayoutLoader && slotLayoutLoader.item && child.hasOwnProperty("isSlotted")) {
                    child.parent = slotLayoutLoader.item.children[0];
                }
            }
        });
    }

    DropArea {
        id: childHandler
        anchors.fill: parent
        objectName: "handler"
        onContainsDragChanged: {
            slotRoot.border.color = containsDrag ? Colors.color.primary : "transparent";
        }
        onChildrenChanged: {
            Qt.callLater(() => {
                if (!childHandler?.children)
                    return;

                const copy = Array.from(childHandler.children);
                const slotted = copy.filter(c => c?.hasOwnProperty("isSlotted")).sort((a, b) => (a?.origParent?.position ?? 0) - (b?.origParent?.position ?? 0));

                const container = slotLayoutLoader?.item?.children?.[0];
                if (!container)
                    return;

                slotted.slice().reverse().forEach(child => {
                    if (child.parent !== container) {
                        child.parent = container;
                    } else {
                        container.children.splice(container.children.indexOf(child), 1);
                        container.children.unshift(child);
                    }
                });
            });
        }
    }

    component RowSlot: RowLayout {
        id: rootRowSlot
        default property alias content: childrenHolder.children

        Row {
            id: childrenHolder
            objectName: modelData.name
            Layout.fillHeight: true
            Layout.alignment: {
                switch (slotRoot.position) {
                case "left" || "top":
                    return Qt.AlignLeft;
                case "right" || "bottom":
                    return Qt.AlignRight;
                case "center":
                    return Qt.AlignCenter;
                default:
                    break;
                }
            }
            spacing: Navbar.config.spacing

            onChildrenChanged: {
                const widgets = childrenHolder.children.filter(c => c.isSlotted !== undefined);
                widgets.forEach((child, index) => {
                    child.implicitHeight = childrenHolder.height;
                    child.y = 0;
                    child.x = 0;
                    const widgetList = Navbar.config.widgets.filter(s => s.layout === modelData.name);
                    const currentChildren = children.filter(s => s.isSlotted);
                    const config = Navbar.config.widgets.find(w => w.name === child.origParent?.widgetName);
                    if (config && widgetList.length === currentChildren.length)
                        config.position = index;
                });
            }
        }

        Component.onDestruction: slotRoot._reparentChildren()
    }

    component ColSlot: ColumnLayout {
        id: rootColSlot
        default property alias content: childrenHolder.children
        Column {
            id: childrenHolder
            objectName: modelData.name
            Layout.fillWidth: true
            Layout.alignment: {
                switch (slotRoot.position) {
                case "left":
                    return Qt.AlignTop;
                case "right":
                    return Qt.AlignBottom;
                case "center":
                    return Qt.AlignCenter;
                default:
                    return;
                }
            }
            spacing: Navbar.config.spacing
            onChildrenChanged: {
                const widgets = childrenHolder.children.filter(c => c.isSlotted !== undefined);
                widgets.forEach((child, index) => {
                    child.implicitHeight = childrenHolder.height;
                    child.y = 0;
                    child.x = 0;
                    const widgetList = Navbar.config.widgets.filter(s => s.layout === modelData.name);
                    const currentChildren = children.filter(s => s.isSlotted);
                    const config = Navbar.config.widgets.find(w => w.name === child.origParent?.widgetName);
                    if (config && widgetList.length === currentChildren.length)
                        config.position = index;
                });
            }
        }

        Component.onDestruction: slotRoot._reparentChildren()
    }

    Component.onDestruction: _onDestruction()

    function _reparentChildren() {
        const target = slotLayoutLoader.item;
        if (target) {
            const copy = target.children[0].children.slice();
            slotRoot.widgets = [];
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (!child.hasOwnProperty("isSlotted"))
                    return;
                const savedWidth = child.width;
                const savedHeight = child.height;
                slotRoot.widgets.push(child);
                child.parent = childHandler;
            }
        }
    }

    function _onDestruction() {
        _reparentChildren();
        slotRoot.slotDestroyed(slotRoot.widgets);
    }

    Component {
        id: colSlot
        ColSlot {}
    }

    Component {
        id: rowSlot
        RowSlot {}
    }

    Loader {
        id: slotLayoutLoader
        sourceComponent: Navbar.config.side ? colSlot : rowSlot
        anchors.fill: parent
        onLoaded: {
            const copy = childHandler.children ? childHandler.children.slice() : [];
            for (let i = 0; i < copy.length; i++) {
                const child = copy[i];
                if (slotLayoutLoader.item && child.hasOwnProperty("isSlotted")) {
                    child.parent = slotLayoutLoader.item.children[0];
                }
            }
        }
    }

    StyledRect {
        id: backgroundRect
        usePanel: true
        width: slotLayoutLoader.item ? slotLayoutLoader.item.children[0].width : 0
        height: slotLayoutLoader.item ? slotLayoutLoader.item.children[0].height : 0
        x: slotLayoutLoader.item ? slotLayoutLoader.item.children[0].x : 0
        y: slotLayoutLoader.item ? slotLayoutLoader.item.children[0].y : 0
        z: -1
        color: Colors.color.background
        border {
            left: Config.general.presets[0].padding.left
            right: Config.general.presets[0].padding.right
            top: Config.general.presets[0].padding.top
            bottom: Config.general.presets[0].padding.bottom
        }
        panelSource: Config.general.presets[0].source
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: Colors.color.primary
        }
    }
}
