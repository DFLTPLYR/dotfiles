import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import qs.config
import qs.components

// General
PageWrapper {
    PageHeader {
        title: "General"
    }
    Spacer {}

    StyledSwitch {
        label: qsTr("Show Preset Creator Grid")
        onClicked: presetGrid.visible = !presetGrid.visible
    }

    FileDialog {
        id: fileDialog
        property Item targetItem
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            targetItem.source = selectedFile;
        }
    }

    GridLayout {
        id: presetGrid
        visible: false
        Layout.fillWidth: true
        Layout.preferredHeight: 600
        columns: 3

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Column {
                spacing: 10
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Preset Name:"
                    color: Colors.color.secondary
                    font.pixelSize: 12
                }
                Rectangle {
                    width: 150
                    height: 20
                    color: Qt.rgba(1, 1, 1, 0.1)
                    clip: true
                    TextInput {
                        id: inputField
                        anchors.fill: parent
                        color: "white"
                        font.pixelSize: parent.height
                    }
                }
                Button {
                    text: "save"
                    enabled: inputField.text.length > 0
                    onClicked: {
                        const preset = {};
                        preset.name = inputField.text;
                        preset.border = {
                            left: acceptButtonBg.border.left,
                            top: acceptButtonBg.border.top,
                            right: acceptButtonBg.border.right,
                            bottom: acceptButtonBg.border.bottom
                        };
                        preset.source = acceptButtonBg.source;
                        Config.general.presets.push(preset);
                        Config.saveSettings();
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Column {
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                Layout.fillWidth: true
                Layout.fillHeight: true
                StyledSpinBox {
                    from: 0
                    onValueChanged: {
                        acceptButtonBg.border.top = value;
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Column {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                Layout.fillWidth: true
                Layout.fillHeight: true

                StyledSpinBox {
                    from: 0
                    onValueChanged: {
                        acceptButtonBg.border.left = value;
                    }
                }
            }
        }

        Rectangle {
            color: "transparent"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Button {
                id: testAcceptButton
                text: "change panel"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                anchors.fill: parent
                background: BorderImage {
                    id: acceptButtonBg
                    anchors {
                        fill: parent
                        margins: 1
                    }
                    border {
                        left: 1
                        top: 1
                        right: 1
                        bottom: 1
                    }
                    horizontalTileMode: BorderImage.Stretch
                    verticalTileMode: BorderImage.Stretch
                }
                onClicked: {
                    fileDialog.targetItem = acceptButtonBg;
                    fileDialog.open();
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Column {
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }

                Layout.fillWidth: true
                Layout.fillHeight: true
                StyledSpinBox {
                    from: 0
                    onValueChanged: {
                        acceptButtonBg.border.right = value;
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            Column {
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                Layout.fillWidth: true
                Layout.fillHeight: true
                StyledSpinBox {
                    from: 0
                    onValueChanged: {
                        acceptButtonBg.border.bottom = value;
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 500
        color: Colors.color.background

        Item {
            id: container

            Rectangle {
                id: draggableImage
                width: 100
                height: 100
                Drag.active: imageMa.drag.active
                Drag.hotSpot.x: 10
                Drag.hotSpot.y: 10

                MouseArea {
                    id: imageMa
                    anchors.fill: parent
                    drag.target: parent
                }
            }

            Repeater {
                model: [
                    {
                        anchors: ["left", "top"]
                    },
                    {
                        anchors: ["right", "top"]
                    },
                    {
                        anchors: ["left", "bottom"]
                    },
                    {
                        anchors: ["right", "bottom"]
                    },
                ]
                delegate: Rectangle {
                    id: cornerHandle
                    z: 10
                    height: 10
                    width: height
                    radius: height / 2
                    color: "green"

                    anchors {
                        horizontalCenter: modelData.anchors.includes("left") ? draggableImage.left : modelData.anchors.includes("right") ? draggableImage.right : undefined
                        verticalCenter: modelData.anchors.includes("top") ? draggableImage.top : modelData.anchors.includes("bottom") ? draggableImage.bottom : undefined
                    }

                    MouseArea {
                        id: cornerPoint
                        anchors.fill: parent
                        drag.target: parent

                        onPositionChanged: mouse => {
                            if (drag.active) {
                                var anchors = modelData.anchors;

                                if (anchors.includes("right")) {
                                    draggableImage.width = Math.max(50, parent.x - draggableImage.x);
                                }
                                if (anchors.includes("left")) {
                                    var newWidth = draggableImage.width + (draggableImage.x - parent.x);
                                    draggableImage.x = parent.x;
                                    draggableImage.width = Math.max(50, newWidth);
                                }
                                if (anchors.includes("bottom")) {
                                    draggableImage.height = Math.max(50, parent.y - draggableImage.y);
                                }
                                if (anchors.includes("top")) {
                                    var newHeight = draggableImage.height + (draggableImage.y - parent.y);
                                    draggableImage.y = parent.y;
                                    draggableImage.height = Math.max(50, newHeight);
                                }
                            }
                        }
                    }

                    states: State {
                        when: cornerPoint.drag.active
                        AnchorChanges {
                            target: cornerHandle
                            anchors {
                                horizontalCenter: undefined
                                verticalCenter: undefined
                            }
                        }
                    }
                }
            }
        }
    }
    Spacer {}

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
}
