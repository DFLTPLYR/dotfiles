import QtQuick
import QtQuick.Layouts

import qs.core

Item {
    id: navbar
    default property alias content: container.data
    property var configFile: Global.fileManager.find(function (s) {
        return s && s.subject === `${screen.name}-navbar`;
    })
    property QtObject config: configFile ? configFile.ref.adapter : null

    property bool side: config ? (config.position === "left" || config.position === "right") : false

    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on y {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on width {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    state: config.position

    states: [
        State {
            name: "left"
            PropertyChanges {
                target: navbar
                x: 0
                y: 0
                width: config ? config.width : 40
                height: parent.height
            }
        },
        State {
            name: "right"
            PropertyChanges {
                target: navbar
                x: parent.width - (config ? config.width : 40)
                y: 0
                width: config ? config.width : 40
                height: parent.height
            }
        },
        State {
            name: "top"
            PropertyChanges {
                target: navbar
                x: 0
                y: 0
                width: parent.width
                height: config ? config.height : 40
            }
        },
        State {
            name: "bottom"
            PropertyChanges {
                target: navbar
                x: 0
                y: parent.height - (config ? config.height : 40)
                width: parent.width
                height: config ? config.height : 40
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            NumberAnimation {
                properties: "x,y,width,height"
                duration: 300
                easing.type: Easing.InOutSine
            }
        }
    ]

    Rectangle {
        id: container
        color: config && config.style ? config.style.color : 'transparent'

        border {
            width: config && config.style && config.style.border ? config.style.border.width : 0
            color: config && config.style && config.style.border ? config.style.border.color : 'transparent'
        }

        anchors {
            fill: parent
            topMargin: config && config.style && config.style.margin ? config.style.margin.top : 0
            bottomMargin: config && config.style && config.style.margin ? config.style.margin.bottom : 0
            leftMargin: config && config.style && config.style.margin ? config.style.margin.left : 0
            rightMargin: config && config.style && config.style.margin ? config.style.margin.right : 0
        }

        GridLayout {
            width: parent.width
            height: parent.height
            flow: navbar.side ? GridLayout.TopToBottom : GridLayout.LeftToRight

            Slot {
                Layout.alignment: navbar.side ? Qt.AlignLeft : Qt.AlignTop | Qt.AlignLeft
            }
            Slot {
                Layout.alignment: navbar.side ? Qt.AlignLeft : Qt.AlignTop | Qt.AlignLeft
            }
            Slot {
                position: "center"
                Layout.alignment: navbar.side ? Qt.AlignLeft : Qt.AlignTop | Qt.AlignLeft
            }
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
            const setHeight = item.setHeight || 100;
            const setWidth = item.setWidth || 100;
            item.width = Qt.binding(() => navbar.side ? slot.width : setWidth);
            item.height = Qt.binding(() => navbar.side ? setHeight : slot.height);
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
            }
        }

        DropArea {
            id: dropArea
            anchors.fill: parent
            onContainsDragChanged: {
                slot.border.color = containsDrag ? "red" : Qt.rgba(0, 0, 0, 0.3);
            }
            onDropped: drop => {
                const isWidget = drop.source.Drag.keys[0];
                if (isWidget) {
                    const item = drop.source;
                    const newParent = innerGrid;
                    const oldParent = item.parent;
                    const oldPosition = item.position;

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
                    }

                    slot.reorderChildren();
                }
            }
        }
    }
}
