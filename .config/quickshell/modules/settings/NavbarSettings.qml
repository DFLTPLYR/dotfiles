import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

import qs.components
import qs.assets

import qs.config

Item {
    id: root

    ScrollView {
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        anchors.right: parent.right
        contentWidth: width
        clip: true

        ColumnLayout {
            width: parent.width
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: "Navbar Configurations"
                color: Color.text
            }
            // Position Settings
            RowLayout {
                Layout.fillWidth: true
                RadioButton {
                    checked: Config.navbar.position === "top"
                    text: qsTr("Top")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "top";
                            Config.navbar.side = false;
                        }
                    }
                }
                RadioButton {
                    checked: Config.navbar.position === "bottom"
                    text: qsTr("Bottom")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "bottom";
                            Config.navbar.side = false;
                        }
                    }
                }
                RadioButton {
                    checked: Config.navbar.position === "right"
                    text: qsTr("Right")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "right";
                            Config.navbar.side = true;
                        }
                    }
                }
                RadioButton {
                    checked: Config.navbar.position === "left"
                    text: qsTr("Left")
                    onCheckedChanged: {
                        if (checked) {
                            Config.navbar.position = "left";
                            Config.navbar.side = true;
                        }
                    }
                }
            }

            // width/height settings
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        visible: !Config.navbar.side
                        text: "Height"
                    }
                    Slider {
                        visible: !Config.navbar.side
                        Layout.fillWidth: true
                        from: 40
                        value: Config.navbar.height
                        to: 100
                        onValueChanged: {
                            Config.navbar.height = value;
                        }
                    }
                    Label {
                        visible: Config.navbar.side
                        text: "Width"
                    }
                    Slider {

                        visible: Config.navbar.side
                        Layout.fillWidth: true
                        from: 40
                        value: Config.navbar.width
                        to: 100
                        onValueChanged: {
                            Config.navbar.width = value;
                        }
                    }
                }
            }

            // Axis position extendedbar settings
            RowLayout {
                visible: Config.navbar.position === "top" || Config.navbar.position === "bottom"
                Layout.fillWidth: true
                Label {
                    text: "Popup X Position"
                }
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 99
                    value: Config.navbar.popup.x
                    onValueChanged: {
                        Config.navbar.popup.x = value;
                    }
                }
            }

            RowLayout {
                visible: Config.navbar.position === "left" || Config.navbar.position === "right"
                Layout.fillWidth: true
                Label {
                    text: "Popup Y Position"
                }
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: Config.navbar.popup.y
                    onValueChanged: {
                        Config.navbar.popup.y = value;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        text: "Popup Height"
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 10
                        value: Config.navbar.popup.height
                        to: 100
                        onValueChanged: {
                            Config.navbar.popup.height = value;
                        }
                    }
                }
                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Label {
                        text: "Popup Width"
                    }
                    Slider {
                        Layout.fillWidth: true
                        from: 10
                        value: Config.navbar.popup.width
                        to: 100
                        onValueChanged: {
                            Config.navbar.popup.width = value;
                        }
                    }
                }
            }

            // workspace style settings
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: Config.navbar.workspaces.styles
                    delegate: RadioButton {
                        required property var modelData
                        checked: Config.navbar.workspaces.style === modelData
                        text: modelData
                        onCheckedChanged: {
                            if (checked) {
                                Config.navbar.workspaces.style = modelData;
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Save Settings"
                }
                Button {
                    text: "Save"
                    onClicked: {
                        Config.saveSettings();
                    }
                }
            }
        }
    }
}
