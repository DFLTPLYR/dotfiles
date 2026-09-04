pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.components
import qs.types
import System

Scope {
    id: dock

    required property string name
    required property int index

    property ShellScreen screen

    signal addDock(var item)
    signal removeDock(int idx)

    objectName: dock.name

    FileView {
        id: file
        path: Qt.resolvedUrl(`${Quickshell.shellDir}/core/data/docks/${screen.name}+${dock.name}.json`)
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
                color: Colors.theme.surface
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
        }
    }

    Connections {
        target: ColorGen
        function onOutput(_result) {
            file.adapter.style.color = Colors.setOpacity(Colors.theme.surface, file.adapter.style.opacity);
            file.writeAdapter();
        }
    }

    // Panel
    LazyLoader {
        id: panelLoader
        active: false
        component: PanelWindow {
            id: panel
            property list<Region> regions: []
            property bool hasFocus: false
            property JsonAdapter config: file.adapter
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
                                    props: Utils.getProperty(widget.property)
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

            implicitWidth: dock.screen.width
            implicitHeight: dock.screen.height

            exclusionMode: config.exclusiveZone ? ExclusionMode.Normal : ExclusionMode.Ignore
            onExclusionModeChanged: {
                if (ExclusionMode.Normal === exclusionMode) {
                    this.exclusiveZone = Qt.binding(() => {
                        return config.side ? config.width : config.height;
                    });
                }
            }

            WlrLayershell.keyboardFocus: panel.hasFocus || modalPopup.opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            WlrLayershell.layer: modalPopup.opened ? WlrLayer.Overlay : WlrLayer.Top
            WlrLayershell.namespace: `Dock-${dock.name}`

            mask: Region {
                regions: panel.regions
            }

            DockContainer {
                id: container
                property Region mask: Region {
                    item: container
                    Component.onCompleted: panel.regions.push(this)
                }
            }

            DockMenu {
                id: modalPopup
                property Region mask: Region {
                    item: modalPopup.opened ? modalPopup.background : null
                    Component.onCompleted: panel.regions.push(this)
                }
                width: Math.min(800, panel.screen.width / 2)
                height: Math.min(1200, panel.screen.height / 2)
                specs: file.adapter
                slots: panel.dockSlots
                onSave: timer.restart()
                onAdd: obj => slotModel.append(obj)
                onRemove: dock.removeDock(index)
            }

            Component.onCompleted: {
                dock.addDock({
                    panel,
                    config,
                    dock
                });
            }
        }
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
                    y: 0
                    x: (parent.width - width) * (config.x / 100)
                    width: parent.width * (config.width / 100)
                    height: config.height
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
                color: Colors.theme.primary
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
                Utils.bindRadii(this, config.style.rounding);
                Utils.bindMargins(this, config.style.margin);
            }
        }

        MouseArea {
            z: -1
            parent: container
            anchors.fill: parent
            propagateComposedEvents: true
            acceptedButtons: modalPopup.opened ? Qt.LeftButton | Qt.RightButton : Qt.RightButton
            onClicked: mouse => {
                const modal = modalPopup;

                const position = mouse => {
                    const clamp = (v, min, max) => Math.max(min, Math.min(max, v));
                    const clickX = container.x + mouse.x;
                    const clickY = container.y + mouse.y;
                    switch (config.position) {
                    case "top":
                        return {
                            x: clamp(clickX - (modal.width / 2), 0, panel.width - modal.width),
                            y: container.y + container.height
                        };
                    case "bottom":
                        return {
                            x: clamp(clickX - (modal.width / 2), 0, panel.width - modal.width),
                            y: container.y - modal.height
                        };
                    case "left":
                        return {
                            x: container.x + container.width,
                            y: clamp(clickY - (modal.height / 2), 0, panel.height - modal.height)
                        };
                    case "right":
                        return {
                            x: container.x - modal.width,
                            y: clamp(clickY - (modal.height / 2), 0, panel.height - modal.height)
                        };
                    default:
                        return {
                            x: clamp(clickX - (modal.width / 2), 0, panel.width - modal.width),
                            y: clamp(clickY - (modal.height / 2), 0, panel.height - modal.height)
                        };
                    }
                };

                if (mouse.button === Qt.RightButton) {
                    const pos = position(mouse);
                    modal.x = pos.x;
                    modal.y = pos.y;
                    modal.opened ? modal.close() : modal.open();
                } else {
                    if (modal.opened)
                        modal.close();
                }
            }

            Component.onCompleted: {
                const reg = Components.createRegion();
                reg.item = this;
                panel.regions.push(reg);
            }
        }
    }

    component Slot: Rectangle {
        id: slot

        signal update(var slot)
        signal remove(int idx)
        property Region region
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
                    border.color: Colors.theme.secondary
                }
            },
            State {
                name: "selected"
                PropertyChanges {
                    target: slot
                    border.width: 2
                    border.color: Colors.theme.tertiary
                }
            }
        ]

        transitions: [
            Transition {
                ColorAnimation {
                    property: "border.color"
                    duration: 150
                }
            }
        ]

        // todo: Do a transfer
        DropArea {
            objectName: "Slot"
            anchors.fill: parent
            onContainsDragChanged: {
                slot.border.width = containsDrag ? 1 : 0;
                slot.border.color = containsDrag ? Colors.theme.tertiary : "transparent";
            }
            onDropped: drop => {
                const source = drop.source.parent;
                const isInternalDrag = source?.widget !== undefined;

                if (isInternalDrag) {
                    // Moving widget from another slot
                    const sourceIndex = source.DelegateModel?.itemsIndex;
                    if (sourceIndex === undefined)
                        return;
                    const obj = source.widget.get(sourceIndex);
                    if (!obj)
                        return;
                    slot.widgets.append(obj);
                    source.widget.remove(sourceIndex, 1);
                    panel.timer.restart();
                } else {
                    // New widget from palette
                    const widget = {
                        source: drop.keys[0],
                        name: Math.random().toString(36).substring(2, 10)
                    };
                    slot.widgets.append(widget);
                    panel.timer.restart();
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
                delegate: Rectangle {
                    id: widgetContainer
                    color: "transparent"
                    required property var modelData
                    required property int index
                    property ListModel widget: widgetsModel.model
                    property string source: modelData.source
                    property var wdg
                    onSourceChanged: widgetContainer.incubateChild()

                    function incubateChild() {
                        const source = modelData?.source;
                        if (!source)
                            return;
                        if (widgetContainer.wdg !== undefined) {
                            widgetContainer.wdg.destroy();
                        }
                        const component = Qt.createComponent(source);
                        if (!component || component.status === Component.Error) {
                            console.warn(`Failed to load widget ${source}: ${component?.errorString() ?? "invalid context"}`);
                            return;
                        }
                        const incubator = component.incubateObject(widgetContainer, {
                            objectName: modelData.name,
                            screen: dock.screen,
                            container: grid,
                            slotConfig: config
                        });
                        if (!incubator)
                            return;
                        const setup = widget => {
                            if (!widget || !widgetContainer)
                                return;
                            widgetContainer.width = Qt.binding(() => {
                                return widget.width;
                            });
                            widgetContainer.height = Qt.binding(() => {
                                return widget.height;
                            });
                            widget.widget = true;
                            if (modelData.props) {
                                Utils.setProperty(widget.property, modelData.props);
                            }
                            panel.activeWidgets = [...panel.activeWidgets, widget];
                            slot.activeWidgets = [...slot.activeWidgets, widget];

                            widgetContainer.wdg = widget;
                            ma.parent = widget;

                            const menu = widget.property.menu;
                            menu.entered.connect(() => {
                                slot.region.item = menu.background;
                                panel.hasFocus = true;
                                return;
                            });
                            menu.exited.connect(hasChanges => {
                                slot.region.item = null;
                                panel.hasFocus = false;

                                if (hasChanges) {
                                    panel.timer.restart();
                                }
                                return;
                            });
                            menu.remove.connect(() => {
                                const container = widgetContainer;
                                container.widget.remove(container.index, 1);

                                panel.timer.restart();
                            });
                        };
                        if (incubator.status === Component.Ready)
                            setup(incubator.object);
                        else
                            incubator.onStatusChanged = status => {
                                if (status === Component.Ready)
                                    setup(incubator.object);
                            };
                    }

                    DropArea {
                        anchors.fill: parent
                        onDropped: drop => {
                            const srcParent = drop.source.parent;
                            const srcDM = srcParent.DelegateModel;
                            const tgtDM = widgetContainer.DelegateModel;
                            const sourceIndex = srcDM?.itemsIndex;
                            const targetIndex = tgtDM?.itemsIndex;

                            if (sourceIndex === undefined || targetIndex === undefined)
                                return;

                            if (tgtDM.model === srcDM.model) {
                                widgetsModel.items.move(sourceIndex, targetIndex);
                            } else {
                                const srcWidgets = srcParent.widget;
                                const tgtWidgets = widgetContainer.widget;
                                const srcObj = JSON.parse(JSON.stringify(srcWidgets.get(sourceIndex)));
                                const tgtObj = JSON.parse(JSON.stringify(tgtWidgets.get(targetIndex)));
                                srcWidgets.set(sourceIndex, tgtObj);
                                tgtWidgets.set(targetIndex, srcObj);
                            }
                            panel.timer.restart();
                        }
                        onContainsDragChanged: {
                            widgetContainer.border.width = containsDrag ? 1 : 0;
                            widgetContainer.border.color = containsDrag ? Colors.theme.tertiary : "transparent";
                        }
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        drag.target: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        propagateComposedEvents: true

                        drag.axis: config.side ? Drag.YAxis : Drag.XAxis
                        onPressAndHold: mouse => {
                            parent.drag.active = true;
                            parent.drag.hotspot = qt.point(mouse.x, mouse.y);
                        }
                        onReleased: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                parent.Drag.drop();
                                parent.x = 0;
                                parent.y = 0;
                                parent.Drag.active = false;
                            }
                        }
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                const menu = widgetContainer.wdg.property.menu;
                                menu.open();
                                menu.x = mouseX;
                                menu.y = mouseY;
                            }
                        }
                    }
                }
            }
        }

        Component.onCompleted: {
            Utils.bindRadii(this, config.style.rounding);

            const reg = Components.createRegion();
            slot.region = reg;
            panel.regions.push(reg);
        }
    }
}
