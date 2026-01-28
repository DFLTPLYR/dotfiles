import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs.utils
import qs.config
import qs.components

PageWrapper {
    id: root
    property ShellScreen selectedScreen: null
    property var areas: []
    property int navbarWidth
    property int navbarHeight

    PageHeader {
        title: "Navbar"
    }
    Spacer {}

    RowLayout {
        id: screenSelector

        StyledButton {
            Layout.preferredWidth: 120
            Layout.preferredHeight: 40
            hoverEnabled: true
            bgColor: root.selectedScreen === null ? Scripts.setOpacity(Colors.color.primary, 0.6) : hovered ? Scripts.setOpacity(Colors.color.primary, 1) : Scripts.setOpacity(Colors.color.background, 1)

            borderRadius: 0
            borderWidth: 1
            borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

            RowLayout {
                anchors {
                    fill: parent
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                FontIcon {
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

                borderRadius: 0
                borderWidth: 1
                borderColor: hovered ? Scripts.setOpacity(Colors.color.secondary, 0.9) : Scripts.setOpacity(Colors.color.primary, 1)

                RowLayout {
                    anchors {
                        fill: parent
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                    FontIcon {
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
        Rectangle {
            Layout.fillWidth: Config.navbar.side ? false : true
            Layout.fillHeight: !Config.navbar.side ? false : true
            Layout.preferredHeight: Config.navbar.height
            Layout.preferredWidth: Config.navbar.width

            color: Colors.color.on_primary
            border.color: Colors.color.primary

            Rectangle {
                id: previewPanelContainer
                visible: true
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                width: Config.navbar.side ? Config.navbar.width / 2 : root.selectedScreen === null ? root.navbarWidth / 2 : root.selectedScreen.width / 2
                height: Config.navbar.side ? root.selectedScreen === null ? root.navbarHeight / 2 : root.selectedScreen.height / 2 : Config.navbar.height / 2
                color: Scripts.setOpacity(Colors.color.background, 0.9)

                GridLayout {
                    anchors.fill: parent
                    columns: Config.navbar.side ? 1 : root.areas.length
                    rows: Config.navbar.side ? root.areas.length : 1

                    Repeater {
                        id: slotRepeater
                        model: ScriptModel {
                            values: root.areas
                        }
                        delegate: Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: modelData.direction

                            objectName: modelData.name
                            color: testingasdf.containsDrag ? "green" : "yellow"
                            DropArea {
                                id: testingasdf
                                anchors.fill: parent
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

            TabBar {
                id: bar
                Layout.fillWidth: true
                TabButton {
                    text: qsTr("Areas")
                }
                TabButton {
                    text: qsTr("Widgets")
                }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: bar.currentIndex

                Item {
                    id: homeTab
                    Row {
                        id: areaLabel

                        Label {
                            text: qsTr("Areas:")
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
                                    idx: root.areas.length,
                                    name: `item-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
                                    direction: Qt.AlignVCenter | Qt.AlignRight,
                                    color: Colors.color.tertiary
                                };
                                root.areas = [...root.areas, container];
                            }
                        }
                    }

                    FlexboxLayout {
                        height: contentHeight
                        width: parent.width
                        anchors.top: areaLabel.bottom
                        gap: 2
                        direction: FlexboxLayout.Column

                        Repeater {
                            model: root.areas
                            delegate: Item {
                                required property var modelData
                                property Item orig: slotRepeater.itemAt(modelData.idx)
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80

                                RowLayout {
                                    anchors.fill: parent

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: modelData.color
                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                const testArray = [Qt.AlignLeft, Qt.AlignHCenter, Qt.AlignRight, Qt.AlignTop, Qt.AlignVCenter, Qt.AlignBottom];
                                                if (orig === null)
                                                    orig = slotRepeater.itemAt(modelData.idx);
                                                const randomAlignment = testArray[Math.floor(Math.random() * testArray.length)];
                                                parent.Layout.alignment = randomAlignment;
                                            }
                                        }
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        StyledButton {
                                            width: 40
                                            height: 40
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: widgetTab

                    Label {
                        text: qsTr("Areas:")
                        font.pixelSize: 32
                        color: Colors.color.on_surface
                    }
                    Item {
                        id: testDragItem
                        property bool isSlotted: false
                        height: (Config.navbar.side && root.isSlotted) ? (parent ? parent.width : 0) : (parent ? parent.height : 0)
                        width: (Config.navbar.side && root.isSlotted) ? (parent ? parent.width : 0) : (parent ? parent.height : 0)

                        MouseArea {
                            id: testDrag
                            onReleased: {
                                console.log(testDragItem.Drag.target);
                            }
                            anchors.fill: parent
                            drag.target: testDragItem
                        }
                        states: [
                            State {
                                when: testDrag.drag.active
                                AnchorChanges {
                                    target: testDragItem
                                    anchors {
                                        verticalCenter: undefined
                                        horizontalCenter: undefined
                                    }
                                }
                            },
                            State {
                                when: !testDrag.drag.active
                                AnchorChanges {
                                    target: testDragItem
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                        ]
                    }
                }
            }
        }
    }

    GridView {
        id: colorGrid
        visible: false
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        cellHeight: width / 15
        cellWidth: width / 15
        model: Colors.colors
        delegate: Rectangle {
            width: colorGrid.cellWidth
            height: colorGrid.cellHeight
            color: Colors.color[modelData]
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
