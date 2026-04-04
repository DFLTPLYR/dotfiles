import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.components
import qs.types

Scope {
    id: dock
    property ShellScreen screen
    required property string name
    signal addDock(var item)

    FileView {
        id: file
        path: Qt.resolvedUrl(`./core/data/docks/${screen.name}+${dock.name}.json`)
        watchChanges: true
        preload: true
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                file.setText("{}");
                file.writeAdapter();
            }
        }
        adapter: JsonAdapter {
            id: config
            property int height: 40
            property int width: 100
            property int x: 0
            property int y: 0
            property string position: "top"
            readonly property bool side: position === "left" || position === "right"
            property StyleJson style: StyleJson {
                color: Colors.setOpacity(Colors.color.background, 0.5)
            }
            property list<var> slots: []

            function save() {
                file.writeAdapter();
            }
            Component.onCompleted: panelLoader.active = true

            function setUp(direction) {
                switch (direction) {
                case "top":
                    break;
                case "bottom":
                    config.position = direction.toString();
                    break;
                case "right":
                case "left":
                    config.position = direction.toString();
                    config.height = 100;
                    config.width = 40;
                    break;
                }
                console.log(direction);
                file.writeAdapter();
            }
        }
    }

    LazyLoader {
        id: panelLoader
        active: false
        component: PanelWindow {
            id: panel
            property JsonAdapter config: file.adapter
            property int size: config.side ? config.width : config.height

            screen: dock.screen
            color: "transparent"
            objectName: dock.name

            anchors {
                top: config.position === "top"
                bottom: config.position === "bottom"
                left: config.position === "left"
                right: config.position === "right"
            }

            // implicitHeight: Global.edit ? screen.height : (config.side ? screen.height : config.height)
            // implicitWidth: Global.edit ? screen.width : (!config.side ? screen.width : config.width)
            implicitWidth: screen.width
            implicitHeight: screen.height

            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.namespace: `Dock-${panel.name}`

            mask: Region {
                regions: [
                    Region {
                        item: container
                    },
                    Region {
                        width: modalPopup.opened ? modalPopup.width : 0
                        height: modalPopup.opened ? modalPopup.height : 0
                        x: modalPopup.opened ? modalPopup.x : 0
                        y: modalPopup.opened ? modalPopup.y : 0
                    }
                ]
            }

            DockContainer {
                id: container
            }

            Modal {
                id: modalPopup
            }

            Component.onCompleted: {
                dock.addDock({
                    panel: panel,
                    config: config
                });
                Global.bindRadii(container, config.style.rounding);
                Global.bindMargins(container, config.style.margin);
            }
        }
    }

    component DockContainer: Rectangle {
        id: container
        color: config.style.color
        state: config.position
        states: [
            State {
                name: "left"
                PropertyChanges {
                    target: container
                    x: 0
                    y: (parent.height - height) * (config.y / 100)
                    width: panel.config.width
                    height: parent.height * (panel.config.height / 100)
                }
            },
            State {
                name: "right"
                PropertyChanges {
                    target: container
                    x: parent.width - config.width
                    y: (parent.height - height) * (config.y / 100)
                    width: config.width
                    height: parent.height * (config.height / 100)
                }
            },
            State {
                name: "top"
                PropertyChanges {
                    target: container
                    width: parent.width * (config.width / 100)
                    height: config.height
                    y: 0
                    x: (parent.width - width) * (config.x / 100)
                }
            },
            State {
                name: "bottom"
                PropertyChanges {
                    target: container
                    y: parent.height - config.height
                    x: (parent.width - width) * (config.x / 100)
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

        DockContentContainer {}

        Loader {
            anchors.fill: parent
            active: Global.edit
            sourceComponent: MouseArea {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    switch (mouse.button) {
                    case Qt.RightButton:
                        if (!modalPopup.opened) {
                            var globalX = mapToItem(null, mouseX, mouseY).x;
                            var globalY = mapToItem(null, mouseX, mouseY).y;
                            var mWidth = screen.width / 4;
                            var mHeight = screen.height / 2;
                            modalPopup.x = mouseX + mWidth > screen.width ? mouseX - mWidth : mouseX;
                            modalPopup.y = globalY + mHeight > screen.height ? globalY - mHeight : globalY;
                        }
                        modalPopup.opened ? modalPopup.close() : modalPopup.open();
                        return;
                    case Qt.LeftButton:
                        if (modalPopup.opened)
                            modalPopup.close();
                        return;
                    default:
                        return;
                    }
                }
            }
        }
    }

    component DockContentContainer: GridLayout {
        id: slotcontainer
        width: parent.width
        height: parent.height
        flow: config.side ? GridLayout.TopToBottom : GridLayout.LeftToRight

        Instantiator {
            model: ScriptModel {
                values: {
                    const data = config.slots;
                    return [...data];
                }
            }
            delegate: Slot {
                required property var modelData
                parent: slotcontainer
                objectName: modelData.name || ""
                position: modelData.position || ""
                spacing: modelData.spacing || 0
            }
        }
    }

    component Slot: Rectangle {
        id: slot
        property bool selected: Global.edit && Global.selectedItem === slot
        onSelectedChanged: slot.state = slot.selected ? "selected" : "none"

        property string position: "left"
        property int spacing: 2
        default property alias content: innerGrid.data
        border.width: 5
        state: "none"

        states: [
            State {
                name: "hovered"
                PropertyChanges {
                    target: slot
                    border.width: 2
                    border.color: Colors.color.tertiary
                }
            },
            State {
                name: "selected"
                PropertyChanges {
                    target: slot
                    border.width: 2
                    border.color: Colors.color.tertiary
                }
            }
        ]

        transitions: [
            Transition {
                to: "hovered"
                NumberAnimation {
                    property: "border.width"
                    duration: 150
                }
                ColorAnimation {
                    property: "border.color"
                    duration: 150
                }
            },
            Transition {
                to: "none"
                NumberAnimation {
                    property: "border.width"
                    duration: 150
                }
                ColorAnimation {
                    property: "border.color"
                    duration: 150
                }
            },
            Transition {
                to: "selected"
                NumberAnimation {
                    property: "border.width"
                    duration: 150
                }
                ColorAnimation {
                    property: "border.color"
                    duration: 150
                }
            }
        ]

        Loader {
            active: Global.edit
            anchors.fill: parent
            sourceComponent: DropArea {
                onContainsDragChanged: {
                    slot.border.color = containsDrag ? Colors.color.tertiary : "transparent";
                }
                onDropped: drop => {
                    console.log(drop);
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onHoveredChanged: {
                if (!slot.state === "selected")
                    slot.state = containsMouse ? "hovered" : "none";
            }
            onClicked: {
                Global.selectedItem = slot;
            }
        }

        color: "transparent"

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 1
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
                flow: config.side ? Grid.TopToBottom : Grid.LeftToRight

                rows: config.side ? children.length : 1
                columns: config.side ? 1 : children.length

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
    }

    component Modal: PopupModal {
        id: modalPopup
        width: screen.width / 4
        height: screen.height / 2

        Rectangle {
            id: tabContainer
            color: Colors.color.background

            implicitHeight: tabbar.height
            width: parent.width

            TabBar {
                id: tabbar
                TabButton {
                    text: "Slots"
                }
                TabButton {
                    text: "Properties"
                }
            }
        }

        StackLayout {
            height: parent.height - tabbar.height
            width: parent.width
            currentIndex: tabbar.currentIndex

            anchors {
                left: modalPopup.left
                right: modalPopup.right
                top: tabContainer.bottom
                bottom: modalPopup.bottom
            }

            Flickable {
                width: parent.width
                height: parent.height
                clip: true
                contentHeight: column.implicitHeight

                Column {
                    id: column
                    width: parent.width
                    Rectangle {
                        id: test
                        color: "blue"
                        width: 400
                        height: 200
                        Drag.active: ma.drag.active
                        Drag.hotSpot: Qt.point(width / 2, height / 2)
                        Drag.onActiveChanged: {
                            if (Drag.active) {
                                test.parent = stack;
                            }
                        }
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            drag.target: test
                            onReleased: {
                                test.parent = column;
                                test.x = 0;
                                test.y = 0;
                            }
                        }
                    }
                }
            }

            PropertyTab {
                id: propertyTab
            }
        }

        Item {
            id: stack
        }
    }

    component PropertyTab: Flickable {
        width: parent.width
        height: parent.height

        ColumnLayout {
            anchors {
                left: parent.left
                right: parent.right
                margins: 2
            }
            Label {
                text: "Slots"
                font.pixelSize: 32
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Button {
                    text: "Add Slot"
                    onClicked: {
                        const slot = {
                            name: Math.random().toString(36).substring(2, 10),
                            position: "left",
                            spacing: 0
                        };
                        config.slots.push(slot);
                    }
                }
            }
        }
    }
}
