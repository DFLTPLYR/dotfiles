import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import QtCore

import Quickshell

import qs.config
import qs.components

// General
PageWrapper {
    PageHeader {
        title: "General"
    }
    Spacer {}

    FileDialog {
        id: fileDialog
        property Item targetItem
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            targetItem.source = selectedFile;
        }
    }

    // margins, padding and rounding
    RowLayout {
        Layout.fillWidth: true
        Layout.minimumHeight: 20
        spacing: 4

        Row {
            Layout.fillWidth: true
            Text {
                color: Colors.color.primary
                text: "Margin: "
                width: 100
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            StyledSpinBox {
                value: Config.general.appearance.margin
                onValueChanged: {
                    Config.general.appearance.margin = value;
                }
            }
        }

        Row {
            Layout.fillWidth: true
            Text {
                color: Colors.color.primary
                text: "Padding: "
                width: 100
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            StyledSpinBox {
                value: Config.general.appearance.padding
                onValueChanged: {
                    Config.general.appearance.padding = value;
                }
            }
        }

        Row {
            Layout.fillWidth: true
            Text {
                color: Colors.color.primary
                text: "Rounding: "
                width: 100
                anchors {
                    verticalCenter: parent.verticalCenter
                }
            }
            StyledSpinBox {
                value: Config.general.appearance.rounding
                onValueChanged: {
                    Config.general.appearance.rounding = value;
                }
            }
        }
    }

    Spacer {}

    StyledSwitch {
        label: qsTr("Show Preset Creator Grid")
        onClicked: presetGrid.visible = !presetGrid.visible
    }

    // preset creator
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

                        preset.padding = {
                            left: acceptButtonBg.border.left,
                            top: acceptButtonBg.border.top,
                            right: acceptButtonBg.border.right,
                            bottom: acceptButtonBg.border.bottom
                        };
                        preset.source = acceptButtonBg.source;
                        const target = Config.general.presets.find(p => p.name === preset.name);

                        if (!target && preset.source) {
                            Config.general.presets.push(preset);
                            Config.saveSettings();
                        }
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

    GridLayout {
        id: presetGridContainer
        Layout.fillWidth: true
        Layout.minimumHeight: 1

        columns: 3

        Instantiator {
            id: presetInstantiator
            model: ScriptModel {
                values: {
                    return Config.general.presets;
                }
            }
            delegate: StyledRect {
                parent: presetGridContainer
                usePanel: true
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                panelSource: modelData ? modelData.source : ""

                border {
                    left: modelData ? modelData.padding.left : 0
                    right: modelData ? modelData.padding.right : 0
                    top: modelData ? modelData.padding.top : 0
                    bottom: modelData ? modelData.padding.bottom : 0
                }

                Column {
                    Text {
                        text: modelData ? modelData.name : ""
                        color: Colors.color.primary
                    }
                    StyledButton {
                        text: "remove"
                        onClicked: {
                            Config.general.presets.splice(index, 1);
                            Config.saveSettings();
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
