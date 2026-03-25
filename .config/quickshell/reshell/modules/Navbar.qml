import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.core

Item {
    id: navbar
    default property alias content: container.data
    property QtObject config: Global.getConfigManager(`${screen.name}-navbar`)?.adapter
    property bool side: config ? (config.position === "left" || config.position === "right") : false
    clip: true

    state: config.position

    states: [
        State {
            name: "left"
            PropertyChanges {
                target: navbar
                x: 0
                y: parent.height * (config.y / 100)
                width: config.width
                height: parent.height * (config.height / 100)
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: navbar
                x: parent.width - config.width
                y: parent.height * (config.y / 100)
                width: config.width
                height: parent.height * (config.height / 100)
            }
        },
        State {
            name: "top"
            PropertyChanges {
                target: navbar
                x: parent.height * (config.x / 100)
                y: 0
                width: parent.width * (config.width / 100)
                height: config.height
            }
        },
        State {
            name: "bottom"
            PropertyChanges {
                target: navbar
                x: parent.height * (config.x / 100)
                y: parent.height - config.height
                width: parent.width * (config.width / 100)
                height: config.height
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            NumberAnimation {
                properties: "width,height"
                duration: 100
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                properties: "x,y"
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }
    ]

    Rectangle {
        id: container
        color: config.style.color

        Behavior on color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 300
                easing.type: Easing.InOutQuad
            }
        }

        border {
            width: config && config.style && config.style.border ? config.style.border.width : 0
            color: config && config.style && config.style.border ? config.style.border.color : 'transparent'
        }

        anchors {
            fill: parent
        }

        GridLayout {
            id: navbarSlot
            width: parent.width
            height: parent.height
            flow: navbar.side ? GridLayout.TopToBottom : GridLayout.LeftToRight

            Instantiator {
                model: config.layouts
                delegate: Slot {
                    required property var modelData
                    objectName: modelData.name || ""
                    position: modelData.position || ""
                    spacing: modelData.spacing || 0
                }
                onObjectAdded: (idx, obj) => {
                    obj.parent = navbarSlot;
                    const file = Global.getConfigManager(`${screen.name}-navbar`);
                    if (!file)
                        return;
                    const index = file.slots.findIndex(s => s.objectName === obj.objectName);
                    if (index !== -1) {
                        file.slots[index] = obj;
                    } else {
                        file.slots.push(obj);
                    }
                    file.reslot();
                }
            }
        }

        Component.onCompleted: {
            Global.bindRadii(container, config.style.rounding);
            Global.bindMargins(container, config.style.margin);
        }
    }

    component Slot: Rectangle {
        id: slot
        property string position: "left"
        property int spacing: 2
        default property alias content: innerGrid.data

        color: "transparent"

        Layout.fillWidth: true
        Layout.fillHeight: true

        onChildrenChanged: {
            for (const i in children) {
                const target = children[i];
                if (target.objectName) {
                    target.parent = innerGrid;
                }
            }
        }

        GridLayout {
            id: grid
            anchors.fill: parent

            Grid {
                id: innerGrid
                flow: navbar.side ? Grid.TopToBottom : Grid.LeftToRight

                rows: navbar.side ? children.length : 1
                columns: navbar.side ? 1 : children.length

                Layout.alignment: {
                    switch (slot.position) {
                    case "left":
                    case "top":
                        return Qt.AlignLeft | Qt.AlignTop;
                    case "right":
                    case "bottom":
                        return Qt.AlignRight | Qt.AlignBottom;
                    case "center":
                        return Qt.AlignCenter;
                    default:
                        return Qt.AlignLeft | Qt.AlignTop;
                    }
                }

                spacing: slot.spacing
                onChildrenChanged: {
                    for (let i = 0; children.length > i; i++) {
                        const target = children[i];
                        slot.bindSize(target);
                    }
                }

                populate: Transition {
                    from: "*"
                    to: "*"
                    NumberAnimation {
                        properties: "x,y,width,height"
                        duration: 300
                        easing.type: Easing.InOutSine
                    }
                }

                add: Transition {
                    from: "*"
                    to: "*"
                    NumberAnimation {
                        properties: "x,y,width,height"
                        duration: 300
                        easing.type: Easing.InOutSine
                    }
                }

                move: Transition {
                    from: "*"
                    to: "*"
                    NumberAnimation {
                        properties: "x,y,width,height"
                        duration: 300
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }

        function bindSize(item) {
            const widget = item.objectName;
            const setHeight = item.setHeight || 100;
            const setWidth = item.setWidth || 100;
            item.implicitWidth = Qt.binding(() => {
                return navbar.side ? slot.width : setWidth;
            });
            item.implicitHeight = Qt.binding(() => {
                return navbar.side ? setHeight : slot.height;
            });
            const exist = navbar.config.custom.widget.find(w => w.objectName === widget);
        }

        // i vibed coded this shit but basically it compares the new position properties from lowest to heigthest then it reparents it
        function reorderChildren(from, to) {
            const children = innerGrid.children.filter(c => c && c.hasOwnProperty('position'));
            children.sort((a, b) => a.position - b.position);
            for (const child of children) {
                child.parent = null;
            }
            for (const child of children) {
                child.parent = innerGrid;
                const exist = navbar.config.widgets.find(s => s.name === child.objectName);
                if (!exist) {
                    const widget = {
                        name: child.objectName,
                        slot: slot.objectName,
                        position: child.position
                    };
                    navbar.config.widgets.push(widget);
                } else {
                    exist.slot = slot.objectName;
                    exist.position = child.position;
                }
            }
        }

        function calculateNewPosition(item, drop, newParent, oldParent, oldPosition) {
            const dropX = drop.x;
            const dropY = drop.y;
            const itemWidth = item.width || 100;
            const itemHeight = item.height || 100;
            let newPosition;
            if (navbar.side) {
                newPosition = Math.round(dropY / itemHeight);
            } else {
                newPosition = Math.round(dropX / itemWidth);
            }
            newPosition = Math.max(0, Math.min(newPosition, newParent.children.length - 1));
            if (oldParent === newParent && oldPosition !== -1) {
                if (oldPosition < newPosition) {
                    for (let i = 0; i < newParent.children.length; i++) {
                        const child = newParent.children[i];
                        if (child && child.hasOwnProperty('position') && child !== item) {
                            if (child.position > oldPosition && child.position <= newPosition) {
                                child.position = child.position - 1;
                            }
                        }
                    }
                } else if (oldPosition > newPosition) {
                    for (let i = 0; i < newParent.children.length; i++) {
                        const child = newParent.children[i];
                        if (child && child.hasOwnProperty('position') && child !== item) {
                            if (child.position >= newPosition && child.position < oldPosition) {
                                child.position = child.position + 1;
                            }
                        }
                    }
                }
                item.position = newPosition;
            } else {
                if (oldParent === newParent) {
                    item.parent = null;
                }
                for (let i = 0; i < newParent.children.length; i++) {
                    const child = newParent.children[i];
                    if (child && child.hasOwnProperty('position') && child.position >= newPosition) {
                        child.position = child.position + 1;
                    }
                }
                item.parent = newParent;
                item.position = newPosition;
                item.opacity = 1;
            }
            return newPosition;
        }

        Loader {
            active: Global.enableSetting
            sourceComponent: DropArea {
                id: dropArea
                onContainsDragChanged: {
                    slot.border.color = containsDrag ? Colors.color.tertiary : "transparent";
                }
                onDropped: drop => {
                    const isWidget = drop.source.Drag.keys[0];
                    if (isWidget) {
                        const item = drop.source;
                        const newParent = innerGrid;
                        const oldParent = item.parent;
                        const oldPosition = item.position;
                        slot.calculateNewPosition(item, drop, newParent, oldParent, oldPosition);
                        slot.reorderChildren();
                    }
                }
            }
            onItemChanged: {
                if (item) {
                    item.width = slot.width;
                    item.height = slot.height;
                }
            }
        }

        Component.onCompleted: {
            const target = Global.slots.find(s => s && s.name === slot.objectName);
            if (target) {
                return target.ref = slot;
            } else {
                Global.slots.push({
                    ref: slot,
                    name: slot.objectName
                });
            }
        }
    }
}
