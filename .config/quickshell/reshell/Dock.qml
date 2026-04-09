import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.core
import qs.components
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

            Modal {
                id: modalPopup
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
                acceptedButtons: Qt.LeftButton | Qt.RightButton
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
            }
        }
    }

    component Slot: Rectangle {
        id: slot

        property string position: "left"
        property int spacing: 2
        property list<var> widgets: []
        default property alias content: innerGrid.data
        state: "none"
        border.width: 2
        clip: true
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
                    slot.widgets = [...slot.widgets, drop.keys[0]];
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
                    values: [...slot.widgets]
                }
                delegate: Loader {
                    required property var modelData
                    parent: innerGrid
                    source: modelData
                    width: config.side ? grid.width : grid.height * 2
                    height: config.side ? grid.width * 2 : grid.height
                }
            }

            Grid {
                id: innerGrid
                flow: config.side ? Grid.TopToBottom : Grid.LeftToRight
                rows: config.side ? children.length : 1
                columns: config.side ? 1 : children.length

                onChildrenChanged: {
                    for (const i in children) {
                        const target = children[i];
                        if (target instanceof Loader) {
                            // target.width = config.side ? grid.width : grid.height * 2;
                            // target.height = config.side ? grid.width * 2 : grid.height;
                            //
                            // target.width = Qt.binding(function () {
                            //     return config.side ? grid.width : grid.height * 4;
                            // });
                            // target.height = Qt.binding(function () {
                            //     return config.side ? grid.width : grid.height;
                            // });
                        }
                    }
                }

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

    component Modal: PopupModal {
        id: modalPopup
        width: Math.min(400, screen.width / 2)
        height: Math.min(600, screen.height / 2)

        // Content
        ColumnLayout {
            anchors.fill: parent

            Rectangle {
                id: tabContainer
                color: Colors.color.background

                Layout.preferredHeight: tabbar.height
                Layout.fillWidth: true

                TabBar {
                    id: tabbar
                    TabButton {
                        text: "Properties"
                    }

                    TabButton {
                        text: "Slots"
                    }

                    TabButton {
                        text: "Widgets"
                    }
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabbar.currentIndex

                PropertyTab {
                    id: propertyTab
                }

                SlotTab {
                    id: slotTab
                }

                WidgetsTab {
                    id: widgetsTab
                }
            }

            Rectangle {
                color: Colors.color.background
                Layout.fillWidth: true
                Layout.preferredHeight: footerContainer.height

                Row {
                    id: footerContainer
                    layoutDirection: Qt.RightToLeft
                    spacing: 0
                    width: parent.width

                    Button {
                        text: "Quit and Save"
                        onClicked: {
                            config.save();
                            Qt.callLater(() => {
                                modalPopup.close();
                            });
                        }
                    }

                    Button {
                        text: "Save"
                        onClicked: config.save()
                    }
                }
            }
        }

        Item {
            id: stack
        }
    }

    component PropertyTab: Flickable {
        width: parent.width
        height: parent.height
        contentHeight: container.height
        clip: true

        ColumnLayout {
            id: container
            anchors {
                left: parent.left
                right: parent.right
                margins: 2
            }
            Button {
                text: "Delete Dock"
                onClicked: dock.removeDock(dock.name)
            }

            Label {
                font.pixelSize: 32
                text: "Dimensions"
            }
            // Width
            Row {
                spacing: 10
                Label {
                    text: "Width"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    stepSize: 1
                    from: 0
                    to: 100

                    value: config.width
                    onValueChanged: config.width = value
                }
            }
            // Height
            Row {
                spacing: 10
                Label {
                    text: "Height"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    stepSize: 1
                    from: 0
                    to: 100

                    value: config.height
                    onValueChanged: config.height = value
                }
            }
            // Position
            Row {
                spacing: 10
                Label {
                    text: config.side ? "y" : "x"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: sliderPos
                    property int barsize: config.side ? config.height : config.width
                    enabled: barsize !== 100

                    from: 0
                    to: 100
                    stepSize: 1

                    value: config.side ? config.y : config.x

                    onValueChanged: {
                        if (config.side) {
                            config.y = value;
                        } else {
                            config.x = value;
                        }
                    }
                }

                Button {
                    text: "center"
                    enabled: sliderPos.enabled
                    onClicked: {
                        sliderPos.value = 50;
                    }
                }
            }
            // rounding
            Label {
                font.pixelSize: 32
                text: "Roundness"
            }
            FlexboxLayout {
                id: rounding
                property var rounding: config.style.rounding
                wrap: FlexboxLayout.Wrap
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                Column {
                    width: rounding.width / 2
                    Label {
                        text: "Top Left"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: rounding.rounding.topLeft
                        onValueChanged: rounding.rounding.topLeft = value
                    }
                }
                Column {
                    width: rounding.width / 2
                    Label {
                        text: "Top Right"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: rounding.rounding.topRight
                        onValueChanged: rounding.rounding.topRight = value
                    }
                }
                Column {
                    width: rounding.width / 2
                    Label {
                        text: "Bottom Left"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: rounding.rounding.bottomLeft
                        onValueChanged: rounding.rounding.bottomLeft = value
                    }
                }
                Column {
                    width: rounding.width / 2
                    Label {
                        text: "Bottom Right"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: rounding.rounding.bottomRight
                        onValueChanged: rounding.rounding.bottomRight = value
                    }
                }
            }
            // margins
            Label {
                font.pixelSize: 32
                text: "Margins"
            }
            FlexboxLayout {
                id: margin
                property var margin: config.style.margin
                wrap: FlexboxLayout.Wrap
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                Column {
                    Label {
                        text: "Top"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: margin.margin.top
                        onValueChanged: margin.margin.top = value
                    }
                }
                Column {
                    Label {
                        text: "Bottom"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: margin.margin.bottom
                        onValueChanged: margin.margin.bottom = value
                    }
                }
                Column {
                    Label {
                        text: "Right"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: margin.margin.right
                        onValueChanged: margin.margin.right = value
                    }
                }
                Column {
                    Label {
                        text: "Left"
                    }
                    SpinBox {
                        width: 100
                        height: 20
                        value: margin.margin.left
                        onValueChanged: margin.margin.left = value
                    }
                }
            }

            // opacity
            Label {
                font.pixelSize: 32
                text: "Opacity"
            }
            Slider {
                id: opacitySlider
                to: 1.0
                onValueChanged: {
                    config.style.opacity = value;
                }
            }
            // Colors
            Label {
                font.pixelSize: 32
                text: "Colors"
            }
            GridView {
                id: colorGrid
                interactive: false
                Layout.fillWidth: true
                Layout.preferredHeight: colorGrid.contentHeight
                cellWidth: colorGrid.width / 4
                cellHeight: cellWidth
                model: [...Colors.colors]
                delegate: Rectangle {
                    width: colorGrid.cellWidth
                    height: colorGrid.cellHeight
                    color: Colors.color[modelData]
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            config.style.color = parent.color;
                        }
                    }
                }
            }
            // Palette
            Label {
                font.pixelSize: 32
                text: "Palette"
            }
            GridView {
                id: paletteGrid
                interactive: false
                Layout.fillWidth: true
                Layout.preferredHeight: paletteGrid.contentHeight
                cellWidth: paletteGrid.width / 4
                cellHeight: cellWidth
                model: [...Colors.palettes]
                delegate: Rectangle {
                    width: paletteGrid.cellWidth
                    height: paletteGrid.cellHeight
                    color: Colors.palette[modelData]
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            config.style.color = parent.color;
                        }
                    }
                }
            }
        }
    }

    component SlotTab: Flickable {
        width: parent.width
        height: parent.height
        contentHeight: container.height
        clip: true

        ColumnLayout {
            id: container
            property var selectedSlot: null

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

            ListView {
                Layout.fillWidth: true
                model: [...config.slots]
                delegate: Button {
                    text: modelData.name
                    onClicked: container.selectedSlot = modelData
                }
            }
        }
    }

    component WidgetsTab: Flickable {
        width: modalPopup.width
        height: modalPopup.height
        clip: true
        contentHeight: column.implicitHeight

        ColumnLayout {
            id: column
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: [...Global.widgets]
                }
                delegate: Item {
                    id: origPlacement
                    width: parent.width
                    height: 100

                    Rectangle {
                        id: container
                        color: Qt.rgba(Math.random(), Math.random(), Math.random(), 0.5)
                        width: origPlacement.width
                        height: origPlacement.height

                        Drag.active: ma.drag.active
                        Drag.keys: [modelData.source]
                        Drag.hotSpot: {
                            switch (config.position) {
                            case "top":
                            case "left":
                                return Qt.point(0, 0);
                            case "bottom":
                                return Qt.point(0, height);
                            case "right":
                                return Qt.point(width, height);
                            default:
                                return Qt.point(0, 0);
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            source: modelData.source
                        }

                        Drag.onActiveChanged: {
                            if (Drag.active) {
                                container.parent = stack;
                            }
                        }

                        states: [
                            State {
                                when: ma.drag.active
                                ParentChange {
                                    target: container
                                    parent: stack
                                }
                            },
                            State {
                                when: !ma.drag.active
                                ParentChange {
                                    target: container
                                    parent: origPlacement
                                }
                            }
                        ]

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            drag.target: container
                            onReleased: {
                                container.x = 0;
                                container.y = 0;
                                container.Drag.drop();
                            }
                        }

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
                    }
                }
            }
        }
    }
}
