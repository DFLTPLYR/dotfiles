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
                Config.saveSettings();
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
                readonly property bool isSelected: Config.navbar.position === modelData

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
                    Config.navbar.position = modelData;
                }
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: root.navbarHeight * 0.6
        columns: Config.navbar.side ? 2 : 1

        // preview Panel
        Item {
            Layout.fillWidth: Config.navbar.side ? false : true
            Layout.fillHeight: !Config.navbar.side ? false : true
            Layout.preferredHeight: Config.navbar.height
            Layout.preferredWidth: Config.navbar.width

            Item {
                id: previewPanelContainer

                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }

                width: Config.navbar.side ? Config.navbar.width / 2 : root.selectedScreen === null ? root.navbarWidth / 2 : root.selectedScreen.width / 2
                height: Config.navbar.side ? root.selectedScreen === null ? root.navbarHeight / 2 : root.selectedScreen.height / 2 : Config.navbar.height / 2

                GridLayout {
                    id: slotGrid
                    anchors.fill: parent
                    columns: Config.navbar.side ? 1 : Config.navbar.layouts.length
                    rows: Config.navbar.side ? Config.navbar.layouts.length : 1

                    Instantiator {
                        id: slotRepeater
                        model: Config.navbar.layouts
                        delegate: StyledSlot {
                            id: slot
                            required property var modelData
                            parent: slotGrid

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            position: modelData.direction

                            Component.onCompleted: {
                                const matchingItems = root.reslot.filter(r => r.name === modelData.name);
                                for (let j = 0; j < matchingItems.length; j++) {
                                    const item = matchingItems[j].item;
                                    if (item) {
                                        item.parent = slot;
                                    }
                                }
                            }
                        }
                    }
                }
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
                                    idx: Config.navbar.layouts.length,
                                    name: `item-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
                                    direction: "left",
                                    color: Colors.color.tertiary
                                };
                                Config.navbar.layouts = [...Config.navbar.layouts, container];
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
                                values: Config.navbar.layouts
                            }
                            delegate: Rectangle {
                                required property var modelData
                                property Item orig: slotRepeater.objectAt(modelData.idx)
                                Layout.preferredWidth: parent.width
                                Layout.preferredHeight: Config.navbar.height
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
                                        onAlignmentChanged: {
                                            const target = Config.navbar.layouts.find(s => s.name === modelData.name);
                                            target.direction = "left";
                                        }
                                    }
                                    AlignmentButton {
                                        Layout.alignment: Qt.AlignCenter
                                        color: {
                                            orig ? orig.position === "center" ? Colors.color.primary : "transparent" : "transparent";
                                        }
                                        onAlignmentChanged: {
                                            const target = Config.navbar.layouts.find(s => s.name === modelData.name);
                                            target.direction = "center";
                                        }
                                    }
                                    AlignmentButton {
                                        Layout.alignment: Qt.AlignRight
                                        color: {
                                            orig ? orig.position === "right" ? Colors.color.primary : "transparent" : "transparent";
                                        }
                                        onAlignmentChanged: {
                                            const target = Config.navbar.layouts.find(s => s.name === modelData.name);
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
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        WidgetWrapper {
                            icon: "clock-nine"
                            widgetName: "Clock"

                            Text {
                                SystemClock {
                                    id: clock
                                    precision: SystemClock.Seconds
                                }

                                text: Qt.formatDateTime(clock.date, "hh:mm AP")
                                color: Colors.color.primary
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    horizontalCenter: parent.horizontalCenter
                                }
                                wrapMode: Text.Wrap
                                width: Math.min(parent.width, font.pixelSize * 6)
                                horizontalAlignment: Text.AlignHCenter
                            }

                            onReparent: (name, item) => {
                                const target = root.reslot.findIndex(s => s.name === name);
                                if (target === -1) {
                                    root.reslot.push({
                                        name: name,
                                        item: item
                                    });
                                } else {
                                    target.name = name;
                                }
                            }
                        }

                        WidgetWrapper {
                            widgetName: "PowerButton"

                            StyledIconButton {
                                property string handler
                                property bool isSlotted: false
                                enabled: false
                                anchors {
                                    verticalCenter: parent ? parent.verticalCenter : undefined
                                }

                                width: parent ? parent.height / 1.5 : 0
                                height: parent ? parent.height / 1.5 : 0
                                radius: parent ? width / 2 : 0

                                Text {
                                    font.family: Config.iconFont.family
                                    font.weight: Config.iconFont.weight
                                    font.styleName: Config.iconFont.styleName
                                    font.pixelSize: Math.min(parent.height, parent.width) / 2

                                    color: "white"
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    text: "power-off"
                                }

                                onAction: {
                                    Config.openSessionMenu = !Config.openSessionMenu;
                                }
                            }
                            onReparent: (name, item) => {
                                const target = root.reslot.findIndex(s => s.name === name);
                                if (target === -1) {
                                    root.reslot.push({
                                        name: name,
                                        item: item
                                    });
                                } else {
                                    target.name = name;
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
            Config.saveSettings();
        }
        onSaveAndExit: {
            Config.general.previewWallpaper = [];
            Config.saveSettings();
            Qt.callLater(() => {
                Config.openSettingsPanel = false;
            });
        }
        onExit: {
            Config.general.previewWallpaper = [];
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
