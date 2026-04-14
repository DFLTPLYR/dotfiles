import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.modules
import qs.types

Item {
    id: dock
    property ShellScreen screen
    required property string name
    signal addDock(var item)
    signal removeDock(string name)
    objectName: dock.name

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
                color: Colors.color.background
                opacity: 0.5
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
                file.writeAdapter();
            }

            function updateColor() {
                config.style.color = Colors.setOpacity(Colors.color.background, config.style.opacity);
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

            implicitWidth: screen.width
            implicitHeight: screen.height

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: config.side ? config.width : config.height
            WlrLayershell.layer: modalPopup.visible ? WlrLayer.Overlay : WlrLayer.Top
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

            DockMenu {
                id: modalPopup
            }

            Background {}

            Component.onCompleted: {
                dock.addDock({
                    panel,
                    config,
                    dock
                });
            }
        }
    }

    component Background: Rectangle {
        id: background

        property bool show: modalPopup.opened

        anchors.fill: parent

        color: "transparent"
        border.width: 2

        onShowChanged: {
            background.state = show ? "show" : "hide";
        }

        state: "hide"

        states: [
            State {
                name: "hide"
                PropertyChanges {
                    target: background
                    opacity: 0
                    border.color: "transparent"
                }
            },
            State {
                name: "show"
                PropertyChanges {
                    target: background
                    opacity: 1
                    border.color: Colors.color.tertiary
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "*"
                NumberAnimation {
                    properties: "opacity"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
                ColorAnimation {
                    properties: "border.color"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        ]
    }

    component DockContainer: Item {
        id: container

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

        opacity: !Global.docks ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            color: Colors.setOpacity(config.style.color, config.style.opacity)
            anchors.fill: parent

            DockContentContainer {}

            Component.onCompleted: {
                Global.bindRadii(this, config.style.rounding);
                Global.bindMargins(this, config.style.margin);
            }
        }

        Loader {
            anchors.fill: parent
            active: Global.edit
            sourceComponent: MouseArea {
                propagateComposedEvents: true
                acceptedButtons: modalPopup.opened ? Qt.LeftButton | Qt.RightButton : Qt.RightButton
                onClicked: mouse => {
                    switch (mouse.button) {
                    case Qt.RightButton:
                        if (!modalPopup.opened) {
                            var globalX = mapToItem(null, mouseX, mouseY).x;
                            var globalY = mapToItem(null, mouseX, mouseY).y;
                            var mWidth = modalPopup.width;
                            var mHeight = modalPopup.height;
                            modalPopup.x = globalX + mWidth > screen.width ? globalX - mWidth : globalX;
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
                widgets: modelData.widgets
            }
        }
    }

    component Slot: Rectangle {
        id: slot

        property string position: "left"
        property int spacing: 2
        property list<var> widgets: []
        property var filteredWidgets: [...widgets].filter(s => s !== undefined)
        default property alias content: innerGrid.data
        state: "none"

        Timer {
            id: syncTimer
            interval: 5000
            running: false
            onTriggered: {
                const cfg = config;
                const data = cfg.slots.find(s => s.name === slot.objectName);
                data.widgets = [...slot.widgets];
                cfg.save();
            }
        }

        border.width: 2

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

        // todo: Do a transfer
        Loader {
            active: Global.edit || Global.widgets
            anchors.fill: parent
            sourceComponent: DropArea {
                onContainsDragChanged: {
                    slot.border.color = containsDrag ? Colors.color.tertiary : "transparent";
                }
                onDropped: drop => {
                    slot.widgets = [...slot.widgets,
                        {
                            source: drop.keys[0],
                            name: Math.random().toString(36).substring(2, 10),
                            position: slot.widgets.length
                        }
                    ];
                }
            }
        }

        color: "transparent"

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: 1

        GridLayout {
            id: grid
            anchors.fill: parent

            Instantiator {
                model: slot.filteredWidgets
                delegate: Item {
                    id: widgetContainer

                    required property var modelData
                    required property int index
                    property var content: widgetLoader
                    property var currentWidget: null

                    parent: innerGrid

                    implicitHeight: widgetContainer?.currentWidget?.height || 0
                    implicitWidth: widgetContainer?.currentWidget?.width || 0

                    LazyLoader {
                        id: widgetLoader
                        active: modelData?.source ? true : ""
                        source: modelData.source
                        onItemChanged: {
                            const timer = syncTimer;
                            const cfg = config;

                            item.parent = widgetContainer;
                            item.config.position = index;
                            item.container = grid;
                            item.containerConfig = cfg;

                            widgetContainer.currentWidget = item;

                            // Signal
                            item.swap.connect((fromIndex, toIndex) => {
                                const containers = innerGrid.children.filter(c => c.content !== undefined);
                                const current = containers.find(c => c.currentWidget?.config?.position === fromIndex);
                                const destination = containers.find(c => c.currentWidget?.config?.position === toIndex);

                                if (!current || !destination)
                                    return;
                                const temp = current.currentWidget;
                                current.currentWidget = destination.currentWidget;
                                destination.currentWidget = temp;
                                current.currentWidget.parent = current;
                                destination.currentWidget.parent = destination;

                                current.currentWidget.config.position = fromIndex;
                                destination.currentWidget.config.position = toIndex;
                                // replace
                                const arr = [...slot.widgets];
                                const temparr = [...arr];
                                [temparr[fromIndex], temparr[toIndex]] = [temparr[toIndex], temparr[fromIndex]];
                                slot.widgets = temparr;
                                timer.restart();
                            });

                            item.remove.connect(idx => {
                                const containers = innerGrid.children.filter(c => c.content !== undefined);
                                const container = containers.find(c => c.currentWidget?.config?.position === idx);
                                if (container) {
                                    container.content.source = "";
                                    container.currentWidget = null;
                                    container.visible = false;
                                }
                                const sub = slot;
                                sub.widgets.splice(idx, 1);
                                timer.restart();
                            });
                        }
                    }
                }
            }

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

        Component.onCompleted: {
            Global.bindRadii(this, config.style.rounding);
        }
    }
}
