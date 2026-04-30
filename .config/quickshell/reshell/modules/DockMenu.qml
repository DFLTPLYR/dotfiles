import QtQuick
import QtQuick.Layouts
import QtQml.Models

import Quickshell

import qs.components
import qs.core

PopupModal {
    id: modal
    property var specs
    property list<var> slots
    property list<var> activeWidgets

    signal add(var obj)
    signal remove
    signal save

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

                TabButton {
                    text: "Active Widget"
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

            ActiveWidgetsTab {
                id: activeWidgetsTab
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
                        modal.save();
                        Qt.callLater(() => {
                            modal.close();
                        });
                    }
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
                onClicked: modal.remove()
            }

            Button {
                text: `${modal.specs.exclusiveZone ? "Disable" : "Enable"} Exclusive Zone`
                onClicked: {
                    modal.specs.exclusiveZone = !modal.specs.exclusiveZone;
                }
            }

            Label {
                font.pixelSize: 32
                text: "Position"
            }

            Row {
                Layout.fillWidth: true
                Repeater {
                    model: ["left", "right", "top", "bottom"]
                    delegate: Button {
                        text: modelData
                        onClicked: modal.specs.position = modelData
                    }
                }
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

                    value: modal.specs.width
                    onValueChanged: modal.specs.width = value
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

                    value: modal.specs.height
                    onValueChanged: modal.specs.height = value
                }
            }
            // Position
            Row {
                spacing: 10
                Label {
                    text: modal.specs.side ? "y" : "x"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: sliderPos
                    property int barsize: modal.specs.side ? modal.specs.height : modal.specs.width
                    enabled: barsize !== 100

                    from: 0
                    to: 100
                    stepSize: 1

                    value: modal.specs.side ? modal.specs.y : modal.specs.x

                    onValueChanged: {
                        if (modal.specs.side) {
                            modal.specs.y = value;
                        } else {
                            modal.specs.x = value;
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
                property var rounding: modal.specs.style.rounding
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
                property var margin: modal.specs.style.margin
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
                    modal.specs.style.opacity = value.toFixed(2);
                }
            }

            // Colors
            Label {
                font.pixelSize: 32
                text: "Colors"
            }
            ColorGrid {
                onSetColor: color => {
                    modal.specs.style.color = color;
                }
            }
            // Palette
            Label {
                font.pixelSize: 32
                text: "Palette"
            }
            PaletteGrid {
                onSetColor: color => {
                    modal.specs.style.color = color;
                }
            }
        }
    }

    component SlotTab: Flickable {
        width: parent.width
        height: parent.height
        contentHeight: container.height
        clip: true

        Connections {
            target: modal
            function onVisibleChanged() {
                if (!container.selectedSlot)
                    return;
                if (modal.visible) {
                    container.selectedSlot.state = "selected";
                } else {
                    container.selectedSlot.state = "none";
                }
            }
        }

        ColumnLayout {
            id: container

            property var selectedSlot: null

            onSelectedSlotChanged: {
                if (modal.visible && container.selectedSlot)
                    container.selectedSlot.state = "selected";
            }

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
                        modal.add(slot);
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                model: [...modal.slots]
                orientation: ListView.Horizontal
                delegate: Rectangle {
                    width: 60
                    height: 40
                    color: modelData.state === "selected" ? Colors.color.primary : Colors.color.background

                    Text {
                        color: modelData.state === "selected" ? Colors.color.on_primary : Colors.color.on_background
                        anchors.centerIn: parent
                        text: modelData.objectName
                    }

                    MouseArea {
                        id: ma
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (modelData.state !== "selected") {
                                modelData.state = containsMouse ? "hovered" : "none";
                            }
                        }
                        anchors.fill: parent
                        onClicked: {
                            if (container.selectedSlot == modelData) {
                                modelData.state = "none";
                                return container.selectedSlot = null;
                            } else {
                                if (container.selectedSlot)
                                    container.selectedSlot.state = "none";
                                container.selectedSlot = modelData;
                            }
                        }
                    }
                }
            }

            Column {
                visible: container.selectedSlot
                Layout.fillWidth: true

                //Position
                Row {
                    Layout.fillWidth: true
                    Repeater {
                        model: modal.specs.side ? ["top", "center", "bottom",] : ["left", "center", "right"]
                        delegate: Button {
                            text: modelData.toUpperCase()
                            onClicked: container.selectedSlot.updatePosition(modelData)
                        }
                    }
                }

                // Remove
                Label {
                    text: "Remove"
                    font.pixelSize: 32
                }

                Button {
                    text: `Remove ${container.selectedSlot?.objectName || null}`
                    onClicked: {
                        container.selectedSlot.removeSlot();
                        Qt.callLater(() => {
                            if (modal.slots.length > 0) {
                                container.selectedSlot = modal.slots[0];
                            }
                        });
                    }
                }
            }
        }
    }

    component WidgetsTab: Flickable {
        width: modal.width
        height: modal.height
        contentHeight: column.height
        clip: true

        ColumnLayout {
            id: column
            width: parent.width

            Repeater {
                model: ScriptModel {
                    values: [...Global.widgets]
                }
                delegate: WidgetPlaceholder {}
            }
        }
    }

    component WidgetPlaceholder: Item {
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
                switch (modal.specs.position) {
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

            LazyLoader {
                active: parent.visible
                source: modelData.source
                onItemChanged: {
                    if (item) {
                        item.parent = container;
                        item.width = container.width;
                        item.height = container.height;
                    }
                }
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

    component ActiveWidgetsTab: Flickable {
        property var selectedWidget: modal.activeWidgets[0] || null

        width: modal.width
        height: modal.height
        contentHeight: container.height
        clip: true

        ColumnLayout {
            id: container
            width: parent.width

            ListView {
                id: widgetList
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                orientation: ListView.Horizontal

                model: ScriptModel {
                    values: [...modal.activeWidgets].filter(s => s !== undefined && s !== null && s.objectName !== null)
                }
                delegate: Button {
                    text: modelData ? modelData.objectName : ""
                    onClicked: {
                        selectedWidget = modelData;
                    }
                }
            }

            ListView {
                id: properties
                Layout.topMargin: widgetList.height
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                orientation: ListView.Vertical

                model: ScriptModel {
                    values: {
                        const data = selectedWidget?.property ? [...selectedWidget.property.keys()].filter(s => s.property !== "position") : [];
                        return [...data];
                    }
                }
                DelegateChooser {
                    id: chooser
                    role: "type"

                    DelegateChoice {
                        roleValue: "number"
                        SpinBox {
                            height: 40

                            width: parent ? parent.width : 0
                            value: selectedWidget ? selectedWidget.property[modelData ? modelData.property : ""] : 0
                            onValueChanged: {
                                if (selectedWidget)
                                    selectedWidget.property[modelData.property] = value;
                            }
                        }
                    }

                    DelegateChoice {
                        roleValue: "string"
                        SpinBox {
                            height: 40
                            width: parent.width
                            value: selectedWidget.property[modelData.property]
                            onValueChanged: {
                                selectedWidget.property[modelData.property] = value;
                            }
                        }
                    }
                }
                delegate: chooser
            }
        }
    }
}
