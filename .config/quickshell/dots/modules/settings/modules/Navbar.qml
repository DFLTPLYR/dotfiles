import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.utils
import qs.config
import qs.components
import qs.widgets

PageWrapper {
    id: root
    property ShellScreen selectedScreen: null
    property int navbarWidth
    property int navbarHeight
    property var tempLayoutChanges: []
    property list<var> reslot: []

    PageHeader {
        title: "Navbar"
    }
    Spacer {}

    onReslotChanged: {
        for (let i = 0; i < slotRepeater.count; i++) {
            const slot = slotRepeater.objectAt(i);
            const slotName = slot.modelData.name;
            const matchingItems = root.reslot.filter(r => r.name === slotName);
            for (let j = 0; j < matchingItems.length; j++) {
                const item = matchingItems[j].item;
                if (item) {
                    item.parent = slot;
                }
            }
        }
    }

    RowLayout {
        id: screenSelector

        StyledButton {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 40
            hoverEnabled: true
            bgColor: root.selectedScreen === null ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.primary, 1) : Scripts.setOpacity(Colors.color.background, 1)

            borderWidth: 1
            borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

            RowLayout {
                anchors {
                    fill: parent
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                FontIcon {
                    Layout.alignment: Qt.AlignCenter
                    text: "monitor"
                    font.pixelSize: parent.height / 2
                    color: Colors.color.secondary
                }
                Text {
                    text: "All"
                    font.pixelSize: parent.height / 2
                    color: Colors.color.secondary
                }
            }

            onClicked: {
                root.selectedScreen = null;
            }
        }

        Repeater {
            model: Quickshell.screens
            delegate: StyledButton {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 40
                hoverEnabled: true
                bgColor: root.selectedScreen === modelData ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.background, 1)

                borderWidth: 1
                borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

                RowLayout {
                    anchors {
                        fill: parent
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                    FontIcon {
                        Layout.alignment: Qt.AlignCenter
                        text: "monitor"
                        font.pixelSize: parent.height / 2
                        color: Colors.color.secondary
                    }
                    Text {
                        text: modelData.name
                        font.pixelSize: parent.height / 2
                        color: Colors.color.secondary
                    }
                }

                onClicked: {
                    root.selectedScreen = modelData;
                }
            }
        }

        StyledButton {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 40
            hoverEnabled: true
            bgColor: root.selectedScreen === null ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.primary, 1) : Scripts.setOpacity(Colors.color.background, 1)

            borderWidth: 1
            borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

            RowLayout {
                anchors {
                    fill: parent
                }

                Text {
                    text: "Save"
                    Layout.alignment: Qt.AlignCenter
                    font.pixelSize: parent.height / 2
                    color: Colors.color.secondary
                }
            }

            onClicked: {
                Navbar.saveSettings();
            }
        }
    }

    Row {
        Label {
            text: qsTr("Panels:")
            font.pixelSize: 32
            color: Colors.color.on_surface
        }
        Repeater {
            id: orientationRepeater
            model: ["top", "bottom", "right", "left"]
            delegate: StyledButton {
                id: orientationBtn
                required property string modelData
                readonly property bool isSelected: Navbar.config.position === modelData

                anchors {
                    verticalCenter: parent.verticalCenter
                }

                height: parent.height * 0.8
                width: height
                enabled: !isSelected

                bgColor: isSelected ? Colors.color.primary : Colors.color.secondary

                FontIcon {
                    text: `bar-${modelData}`
                    color: isSelected ? Colors.color.on_primary : Colors.color.on_secondary

                    font.pixelSize: parent.height * 0.8

                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                onClicked: {
                    Navbar.config.position = modelData;
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: root.navbarHeight * 0.6
        columns: Navbar.config.side ? 2 : 1

        // preview Panel
        Item {
            Layout.fillWidth: Navbar.config.side ? false : true
            Layout.fillHeight: !Navbar.config.side ? false : true
            Layout.preferredHeight: Navbar.config.height
            Layout.preferredWidth: Navbar.config.width

            Item {
                id: previewPanelContainer

                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                width: Navbar.config.side ? Navbar.config.width / 2 : root.selectedScreen === null ? root.navbarWidth / 2 : root.selectedScreen.width / 2
                height: Navbar.config.side ? root.selectedScreen === null ? root.navbarHeight / 2 : root.selectedScreen.height / 2 : Navbar.config.height / 2

                GridLayout {
                    id: slotGrid
                    anchors.fill: parent
                    columns: Navbar.config.side ? 1 : Navbar.config.layouts.length
                    rows: Navbar.config.side ? Navbar.config.layouts.length : 1

                    Instantiator {
                        id: slotRepeater
                        model: Navbar.config.layouts
                        delegate: StyledSlot {
                            id: slot
                            required property var modelData
                            parent: slotGrid

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            position: modelData.direction
                            objectName: modelData.name

                            onSlotDestroyed: function (widgets) {
                                widgetHolder.returnChildrenToHolder(widgets, modelData.name);
                            }

                            Component.onCompleted: {
                                Qt.callLater(() => widgetHolder.reparent());
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: widgetHolder
            visible: false

            function returnChildrenToHolder(widgets, slotName) {
                for (let i = 0; i < widgets.length; i++) {
                    let child = widgets[i];
                    if (child.handler === slotName) {
                        child.parent = this;
                    }
                }
            }

            function reparent() {
                const slotMap = Array.from({
                    length: slotRepeater.count
                }, (_, i) => slotRepeater.objectAt(i)).filter(slot => slot && slot.modelData).reduce((map, slot) => {
                    map[slot.modelData.name] = slot;
                    return map;
                }, {});
                children.forEach(child => {
                    const slot = slotMap[child.parentName];
                    if (slot) {
                        child.parent = slot;
                    }
                });
            }
        }

        // Options/Settings panel
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            // tabs
            TabBar {
                id: bar
                Layout.fillWidth: true
                TabButton {
                    text: qsTr("Slots")
                }
                TabButton {
                    text: qsTr("Widgets")
                }
            }

            // contents
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: bar.currentIndex

                Item {
                    id: slotsTab

                    Row {
                        id: slotLabel

                        Label {
                            text: qsTr("Slots:")
                            font.pixelSize: 32
                            color: Colors.color.on_surface
                        }

                        StyledButton {
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            height: parent.height * 0.8
                            width: height

                            FontIcon {
                                text: "plus"
                                color: Colors.color.secondary
                                font.pixelSize: parent.height * 0.8

                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    horizontalCenter: parent.horizontalCenter
                                }
                            }
                            onClicked: {
                                const container = {
                                    idx: Navbar.config.layouts.length,
                                    name: `item-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
                                    direction: "left",
                                    color: Colors.color.tertiary
                                };
                                Navbar.config.layouts = [...Navbar.config.layouts, container];
                            }
                        }
                    }

                    FlexboxLayout {
                        height: contentHeight
                        width: parent.width
                        anchors.top: slotLabel.bottom
                        gap: 2
                        wrap: FlexboxLayout.Wrap

                        Repeater {
                            model: ScriptModel {
                                values: Navbar.config.layouts
                            }
                            delegate: Rectangle {
                                required property var modelData
                                property Item orig: slotRepeater.objectAt(modelData.idx)
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: Navbar.config.height
                                color: "transparent"
                                border.color: Colors.color.primary

                                HoverHandler {
                                    id: mouse
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    cursorShape: Qt.PointingHandCursor
                                    onHoveredChanged: {
                                        if (orig === null) {
                                            orig = slotRepeater.objectAt(modelData.idx);
                                        }
                                        orig.border.color = !hovered ? "transparent" : Colors.color.tertiary;
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    opacity: mouse.hovered ? 1 : 0

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.InOutQuad
                                        }
                                    }

                                    AlignmentButton {
                                        Layout.alignment: Qt.AlignLeft
                                        color: {
                                            orig ? orig.position === "left" ? Colors.color.primary : "transparent" : "transparent";
                                        }
                                        position: "left"
                                        onAlignmentChanged: {
                                            const target = Navbar.config.layouts.find(s => s.name === modelData.name);
                                            target.direction = "left";
                                        }
                                    }
                                    AlignmentButton {
                                        Layout.alignment: Qt.AlignCenter
                                        color: {
                                            orig ? orig.position === "center" ? Colors.color.primary : "transparent" : "transparent";
                                        }
                                        position: "center"
                                        onAlignmentChanged: {
                                            const target = Navbar.config.layouts.find(s => s.name === modelData.name);
                                            target.direction = "center";
                                        }
                                    }
                                    AlignmentButton {
                                        Layout.alignment: Qt.AlignRight
                                        color: {
                                            orig ? orig.position === "right" ? Colors.color.primary : "transparent" : "transparent";
                                        }
                                        position: "right"
                                        onAlignmentChanged: {
                                            const target = Navbar.config.layouts.find(s => s.name === modelData.name);
                                            target.direction = "right";
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: widgetTab

                    Label {
                        text: qsTr("Widgets:")
                        font.pixelSize: 32
                        color: Colors.color.on_surface
                    }

                    FlexboxLayout {
                        id: wrapperLayout
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Instantiator {
                            model: ScriptModel {
                                values: Navbar.config.widgets.slice().sort((a, b) => a.position - b.position)
                            }
                            delegate: LazyLoader {
                                required property var modelData
                                active: true
                                component: WidgetWrapper {
                                    parent: wrapperLayout
                                    icon: modelData.icon
                                    widgetName: modelData.name
                                    contentHeight: modelData.height
                                    contentWidth: modelData.width

                                    onReparent: (name, item) => {
                                        const slotMap = Array.from({
                                            length: slotRepeater.count
                                        }, (_, i) => slotRepeater.objectAt(i)).filter(slot => slot && slot.modelData).reduce((map, slot) => {
                                            map[slot.modelData.name] = slot;
                                            return map;
                                        }, {});
                                        const slot = slotMap[name];
                                        if (slot && name !== "") {
                                            item.parent = slot;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component AlignmentButton: Rectangle {
        signal alignmentChanged
        property string position
        Layout.fillHeight: true
        Layout.preferredWidth: height
        radius: height / 2

        border.color: ma.containsMouse ? Colors.color.primary : "transparent"
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
        Text {
            text: position
            anchors.centerIn: parent
            color: Colors.color.primary
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (orig === null) {
                    orig = slotRepeater.itemAt(modelData.idx);
                }
                alignmentChanged();
            }
        }
    }

    PageFooter {
        onSave: {
            Navbar.saveSettings();
        }
        onSaveAndExit: {
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
        onExit: {
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
    }

    Component.onCompleted: {
        const objects = Quickshell.screens;
        objects.forEach(obj => {
            if (obj.width > root.navbarWidth)
                root.navbarWidth = obj.width;
            if (obj.height > root.navbarHeight)
                root.navbarHeight = obj.height;
        });
    }
}
