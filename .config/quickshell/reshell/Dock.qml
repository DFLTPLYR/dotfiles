pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.components
import qs.modules
import qs.types

Item {
    id: dock

    required property string name
    required property int index

    property ShellScreen screen

    signal addDock(var item)
    signal removeDock(int idx)

    objectName: dock.name

    FileView {
        id: file
        path: Qt.resolvedUrl(`./core/data/docks/${screen.name}+${dock.name}.json`)
        watchChanges: true
        preload: true
        blockLoading: true
        onLoaded: {
            panelLoader.active = true;
        }
        onSaved: {
            if (!panelLoader.active)
                panelLoader.active = true;
        }
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
            property bool exclusiveZone: false
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
            property var modal: null
            property int size: config.side ? config.width : config.height
            property list<var> dockSlots: []
            property list<var> activeWidgets: []
            property var timer

            property ListModel slots: ListModel {
                id: slotModel

                function sync() {
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
                            widgets: [],
                            position: item.position,
                            spacing: item.spacing
                        };
                        for (let i = 0; i < item.widgets.count; i++) {
                            const target = item.widgets.get(i).name;
                            const widget = item.activeWidgets.find(s => s?.objectName === target);

                            if (widget) {
                                data.widgets[i] = {
                                    name: widget.objectName,
                                    source: widget.parent.modelData.source,
                                    props: widget.property.getProperty()
                                };
                            }
                        }
                        slot.push(data);
                    }

                    cfg.slots = [...slot].filter(s => s.position !== null && s.position !== undefined);
                    cfg.save();
                }

                Component.onCompleted: {
                    const container = config.slots;
                    for (const i in container) {
                        slotModel.append(container[i]);
                    }
                }
            }

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

            exclusionMode: config.exclusiveZone ? ExclusionMode.Normal : ExclusionMode.Ignore
            onExclusionModeChanged: {
                if (ExclusionMode.Normal === exclusionMode) {
                    this.exclusiveZone = config.side ? config.width : config.height;
                }
            }

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
                    },
                    Region {
                        item: panel.modal ? panel.modal.background : null
                    }
                ]
            }

            DockContainer {
                id: container
            }

            DockMenu {
                id: modalPopup
                dim: true
                width: Math.min(800, panel.screen.width / 2)
                height: Math.min(1200, panel.screen.height / 2)
                specs: file.adapter
                slots: panel.dockSlots
                onSave: timer.restart()
                onAdd: obj => slotModel.append(obj)
                onRemove: dock.removeDock(index)
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
                flow: config.side ? GridLayout.TopToBottom : GridLayout.LeftToRight

                Instantiator {
                    model: panel.slots
                    delegate: Slot {
                        required property QtObject model
                        required property int index
                        parent: slotcontainer
                        objectName: model.name
                        position: model.position
                        spacing: model.spacing
                        widgets: model.widgets

                        onRemove: idx => {
                            panel.slots.remove(idx, 1);
                        }
                    }

                    onObjectRemoved: (idx, obj) => {
                        panel.dockSlots.splice(idx, 1);
                    }

                    onObjectAdded: (idx, obj) => {
                        panel.dockSlots.push(obj);
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
                    panel.slots.sync();
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
                            modalPopup.y = panel.height / 2 - modalPopup.height / 2;
                            modalPopup.x = panel.width / 2 - modalPopup.width / 2;
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
        signal remove(int idx)
        property string position: "left"
        property int spacing: 2
        property ListModel widgets
        property list<var> activeWidgets: []

        function removeSlot() {
            slot.remove(index);
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
            active: Global.edit || Global.widget
            anchors.fill: parent
            sourceComponent: DropArea {
                objectName: "Slot"
                onContainsDragChanged: {
                    slot.border.width = containsDrag ? 1 : 0;
                    slot.border.color = containsDrag ? Colors.color.tertiary : "transparent";
                }
                onDropped: drop => {
                    switch (Global.state) {
                    case Global.states.edit:
                        const widget = {
                            source: drop.keys[0],
                            name: Math.random().toString(36).substring(2, 10)
                        };
                        slot.widgets.append(widget);
                        return;
                    case Global.states.widget:
                        const target = drop.source.parent;
                        const delegateModel = target.DelegateModel;
                        const index = delegateModel.itemsIndex;
                        const obj = target.widget.get(index);
                        slot.widgets.append(obj);
                        target.widget.remove(index, 1);
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

            ListView {
                id: widgetList
                interactive: false
                orientation: config.side ? ListView.Vertical : ListView.Horizontal
                spacing: slot.spacing
                model: widgetsModel
                cacheBuffer: 50

                Layout.preferredHeight: config.side ? contentHeight : parent.height
                Layout.preferredWidth: config.side ? parent.width : contentWidth
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
            }

            DelegateModel {
                id: widgetsModel
                model: slot.widgets
                delegate: Pane {
                    id: widgetContainer
                    required property var modelData
                    required property int index
                    property ListModel widget: widgetsModel.model
                    property string source: modelData.source
                    onSourceChanged: incubateChild()

                    function incubateChild() {
                        const component = Qt.createComponent(modelData.source);
                        const incubator = component.incubateObject(widgetContainer, {
                            objectName: modelData.name,
                            screen: dock.screen,
                            container: grid,
                            slotConfig: config
                        });
                        if (incubator.status !== Component.Ready) {
                            incubator.onStatusChanged = function (status) {
                                if (status === Component.Ready) {
                                    const widget = incubator.object;
                                    if (!widget)
                                        return;
                                    widgetContainer.width = Qt.binding(() => {
                                        return widget.width;
                                    });
                                    widgetContainer.height = Qt.binding(() => {
                                        return widget.height;
                                    });
                                    if (modelData.props) {
                                        widget.property.setProperty(modelData.props);
                                    }
                                    panel.activeWidgets = [...panel.activeWidgets, widget];
                                    slot.activeWidgets = [...slot.activeWidgets, widget];

                                    widget.swap.connect((fromIndex, toIndex) => {
                                        widgetsModel.items.move(fromIndex, toIndex);
                                        panel.timer.restart();
                                    });

                                    widget.remove.connect(() => {
                                        widgetsModel.items.remove(widgetContainer.index, 1);
                                        panel.timer.restart();
                                    });

                                    widget.modal.connect(modal => {
                                        if (modal === null) {
                                            panel.timer.restart();
                                        }
                                        panel.modal = modal;
                                    });
                                }
                            };
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            Global.bindRadii(this, config.style.rounding);
        }
    }
}
