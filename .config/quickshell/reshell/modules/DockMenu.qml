import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.components
import qs.core

PopupModal {
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
            property var selectedSlot: config.slots[0] || null

            anchors {
                left: parent.left
                right: parent.right
                margins: 2
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Slots"
                    font.pixelSize: 32
                }
                Button {
                    text: "Add Slot"
                    onClicked: {
                        const slot = {
                            name: Math.random().toString(36).substring(2, 10),
                            position: "left",
                            spacing: 0,
                            widgets: []
                        };
                        config.slots.push(slot);
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                model: [...config.slots]
                delegate: Button {
                    text: modelData.name
                    onClicked: container.selectedSlot = modelData
                }
            }

            Label {
                text: "Delete"
                font.pixelSize: 32
            }
            Button {
                text: `Delete ${container.selectedSlot?.name || null}`
                onClicked: {
                    const item = config.slots.find(s => s.name === container.selectedSlot.objectName);
                    print(item);
                }
            }
        }
    }

    component WidgetsTab: Flickable {
        width: modalPopup.width
        height: modalPopup.height
        contentHeight: column.height
        clip: true

        ColumnLayout {
            id: column
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: [...Global.widgets]
                }
                delegate: Item {
                    id: origPlacement
                    Layout.fillWidth: true
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.preferredHeight: 100
                    Rectangle {
                        id: container
                        color: "transparent"

                        width: origPlacement.width
                        height: origPlacement.height
                        border.color: Colors.color.primary
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
