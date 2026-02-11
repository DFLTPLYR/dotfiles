import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import Quickshell
import Quickshell.Io

import qs.config
import qs.utils
import qs.config
import qs.assets
import qs.services

Item {
    id: root
    property var module
    property string location
    Component {
        id: portraitLayout
        ColumnLayout {
            height: parent.height
            Loader {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.width

                Layout.alignment: Qt.AlignBottom

                height: parent.width
                sourceComponent: CustomButton {}

                onLoaded: {
                    item.buttonText = "power_settings_new";
                    item.onClickedAction = function () {
                        Config.sessionMenuOpen = true;
                    };
                }
            }
        }
    }

    Component {
        id: landscapeLayout
        RowLayout {
            height: parent.height
            layoutDirection: Qt.RightToLeft

            Loader {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.height
                height: parent.height
                sourceComponent: CustomButton {}

                onLoaded: {
                    item.buttonText = "power_settings_new";
                    item.onClickedAction = function () {
                        Config.sessionMenuOpen = true;
                    };
                }
            }
        }
    }

    component CustomButton: Item {
        property string buttonText: ""
        property var onClickedAction: function () {}

        width: parent.width
        height: parent.height

        Rectangle {
            anchors.fill: parent
            radius: height * 0.2
            color: ma.containsMouse ? Scripts.setOpacity(Color.color14, 0.4) : Color.color2

            Behavior on color {
                ColorAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                text: buttonText
                anchors.centerIn: parent
                font.pixelSize: {
                    var minSize = 10;
                    return Math.max(minSize, Math.min(height, width) * 0.6);
                }

                font.family: FontProvider.fontMaterialOutlined

                color: Color.color14

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                Behavior on color {
                    ColorAnim {}
                }
            }
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
                onClicked: onClickedAction()
            }
        }
    }

    Loader {
        id: layoutLoader
        height: parent.height
        sourceComponent: Navbar.config.side ? portraitLayout : landscapeLayout
    }
}
