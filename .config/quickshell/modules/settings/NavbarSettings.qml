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
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
            }
        }
    }
}
