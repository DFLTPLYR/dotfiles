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

    required property string name
    property ShellScreen screen

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
            property list<var> dockSlots: []
            property var timer

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
                slots: panel.dockSlots
                onSave: {
                    timer.restart();
                }
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
            clip: true

            GridLayout {
                id: slotcontainer

                width: parent.width
                height: parent.height
                onChildrenChanged: {
                    const slots = [...children].filter(s => s instanceof Slot);
                    if (slots.length === config.slots.length) {
                        slots.sort((a, b) => (a.position || 0) - (b.position || 0));
                        children = slots;
                        slotcontainer.activeFocusOnTabChanged;
                        panel.dockSlots = slots;
                    }
                }
                flow: config.side ? GridLayout.TopToBottom : GridLayout.LeftToRight

                Instantiator {
                    model: config.slots.filter(s => s !== undefined)
                    delegate: Slot {
                        required property var modelData
                        required property int index
                        objectName: modelData.name
                        position: modelData.position
                        spacing: modelData.spacing
                        widgets: modelData.widgets
                        parent: slotcontainer
                        onUpdate: slot => {
                            if (slot) {
                                syncTimer.slots = slot;
                            }
                            syncTimer.restart();
                        }
                    }
                }
            }

            Rectangle {
                id: timerProgress
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                height: 2
                color: Colors.color.primary
                z: 100

                NumberAnimation on width {
                    from: 0
                    to: parent ? slotcontainer.width : 0
                    duration: syncTimer.interval
                    running: syncTimer.running
                    onFinished: {
                        timerProgress.width = 0;
                    }
                }
            }

            Timer {
                id: syncTimer
                property list<var> slots
                interval: 1000
                running: false
                onTriggered: {
                    const cfg = config;
                    if (slots.length >= 1) {
                        cfg.slots = [...syncTimer.slots].filter(s => s.position !== null && s.position !== undefined);
                        cfg.save();
                        return;
                    }
                    let slot = [];
                    for (const i in panel.dockSlots) {
                        const item = panel.dockSlots[i];
                        const data = {
                            name: item.objectName,
                            widgets: item.filteredWidgets,
                            position: item.position,
                            spacing: item.spacing
                        };
                        slot.push(data);
                    }
                    cfg.slots = [...slot].filter(s => s.position !== null && s.position !== undefined);
                    cfg.save();
                }
                Component.onCompleted: panel.timer = syncTimer
            }

            Component.onCompleted: {
                Global.bindRadii(this, config.style.rounding);
                Global.bindMargins(this, config.style.margin);
            }
        }

        LazyLoader {
            active: Global.edit
            component: MouseArea {
                parent: container
                anchors.fill: parent
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

    component Slot: Rectangle {
        id: slot
        signal update(var slot)
        property string position: "left"
        property int spacing: 2
        property list<var> widgets: []
        property var filteredWidgets: [...widgets].filter(s => s !== undefined)
        default property alias content: innerGrid.data

        function removeSlot() {
            const idx = config.slots.findIndex(s => s.name === slot.objectName);
            if (idx !== -1) {
                config.slots.splice(idx, 1);
            }
        }

        function updateSlot() {
            const idx = config.slots.findIndex(s => s.name === slot.objectName);
            if (idx !== -1) {
                const replace = {
                    position: slot.position,
                    spacing: slot.spacing,
                    widgets: [...slot.filteredWidgets],
                    name: slot.objectName
                };
            }
        }

        function updatePosition(pos) {
            switch (pos) {
            case "center":
                slot.position = "center";
                return;
            case "bottom":
            case "right":
                slot.position = "right";
                return;
            case "top":
            case "left":
                slot.position = "left";
                return;
            }
        }

        state: "none"

        states: [
            State {
                name: "none"
                PropertyChanges {
                    target: slot
                    border.width: 0
                    border.color: "transparent"
                }
            },
            State {
                name: "hovered"
                PropertyChanges {
                    target: slot
                    border.width: 2
                    border.color: Colors.color.secondary
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
                    switch (Global.state) {
                    case Global.states.edit:
                        slot.widgets = [...slot.widgets,
                            {
                                source: drop.keys[0],
                                name: Math.random().toString(36).substring(2, 10),
                                position: slot.widgets.length
                            }
                        ];
                        slot.update(null);
                        return;
                    case Global.states.widget:
                        if (drop.source.parent.parent === innerGrid) {
                            return;
                        }
                        drop.source.parent.parent = innerGrid;
                        let slots = [];

                        let foundWidget = null;
                        let foundSlot = null;
                        for (const slot of config.slots) {
                            for (const widget of slot.widgets) {
                                if (widget.name === drop.source.objectName) {
                                    foundWidget = widget;
                                    foundSlot = slot;
                                    break;
                                }
                            }
                            if (foundWidget)
                                break;
                        }

                        for (const i in panel.dockSlots) {
                            const item = panel.dockSlots[i];
                            const data = {
                                name: item.objectName,
                                widgets: item.widgets,
                                spacing: item.spacing,
                                position: item.position
                            };
                            if (item.objectName === foundSlot.name)
                                data.widgets = data.widgets.filter(s => s.name !== foundWidget.name);
                            if (item.objectName === slot.objectName)
                                data.widgets = [...data.widgets, foundWidget];
                            slots.push(data);
                        }

                        slot.update(slots);
                        return;
                    default:
                        return;
                    }
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
                model: ScriptModel {
                    values: [...slot.filteredWidgets]
                }
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
                            const slt = slot;

                            item.parent = widgetContainer;
                            item.objectName = modelData.name;
                            item.property.position = index;
                            item.container = grid;
                            item.slotConfig = config;
                            widgetContainer.currentWidget = item;

                            const findByPosition = pos => innerGrid.children.find(c => c.currentWidget?.property?.position === pos);

                            item.swap.connect((fromIndex, toIndex) => {
                                const current = findByPosition(fromIndex);
                                const destination = findByPosition(toIndex);

                                if (!current || !destination)
                                    return;
                                const temp = current.currentWidget;
                                current.currentWidget = destination.currentWidget;
                                destination.currentWidget = temp;
                                current.currentWidget.parent = current;
                                destination.currentWidget.parent = destination;
                                current.currentWidget.property.position = fromIndex;
                                destination.currentWidget.property.position = toIndex;
                                const arr = [...slt.widgets];
                                [arr[fromIndex], arr[toIndex]] = [arr[toIndex], arr[fromIndex]];
                                slt.widgets = arr;
                                slt.update(null);
                            });

                            item.remove.connect(idx => {
                                const container = findByPosition(idx);
                                if (container) {
                                    container.content.source = "";
                                    container.currentWidget = null;
                                    container.visible = false;
                                }
                                slt.widgets.splice(idx, 1);
                                slt.update(null);
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
