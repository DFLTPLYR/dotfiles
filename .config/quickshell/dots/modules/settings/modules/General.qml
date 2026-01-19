import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.config
import qs.components

// General
PageWrapper {
    PageHeader {
        title: "General"
    }
    Spacer {}

    Switch {
        text: qsTr("Show Preset Creator Grid")
        onClicked: presetGrid.visible = !presetGrid.visible
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
                Label {
                    text: "Preset Name:"
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
                SpinBox {
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

                SpinBox {
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
                SpinBox {
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
                SpinBox {
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
