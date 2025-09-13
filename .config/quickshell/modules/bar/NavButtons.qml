import QtQuick
import QtQuick.Controls
import Quickshell

import qs
import qs.utils
import qs.assets

Item {
    id: root
    implicitWidth: parent.width
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter

    Component {
        id: navButtonComponent
        Item {
            width: 32
            height: 32
            property string buttonText: ""
            property var onClickedAction: function () {}
            RoundButton {
                anchors.centerIn: parent
                width: parent.width * 0.7
                height: parent.height * 0.7
                hoverEnabled: true

                text: buttonText
                font.pixelSize: 16
                font.family: FontProvider.fontMaterialOutlined
                contentItem: Text {
                    text: parent.text
                    color: ColorPalette.color14
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Behavior on color {
                        AnimationProvider.ColorAnim {}
                    }
                }

                background: Rectangle {
                    color: ColorPalette.color0
                    radius: width / 2
                    border.color: ColorPalette.color10
                    border.width: 1

                    Behavior on color {
                        AnimationProvider.ColorAnim {}
                    }
                    Behavior on border.color {
                        AnimationProvider.ColorAnim {}
                    }
                }

                onHoveredChanged: {
                    if (hovered) {
                        background.color = ColorPalette.color2;
                        contentItem.color = ColorPalette.color15;
                    } else {
                        background.color = ColorPalette.color0;
                        contentItem.color = ColorPalette.color14;
                    }
                }
                onClicked: onClickedAction()
            }
        }
    }

    Row {
        anchors.fill: parent
        layoutDirection: Qt.RightToLeft

        Loader {
            sourceComponent: navButtonComponent
            onLoaded: {
                item.buttonText = "power_settings_new";
                item.onClickedAction = function () {
                    GlobalState.isSessionMenuOpen = true;
                };
            }
        }

        Loader {
            sourceComponent: navButtonComponent
            onLoaded: item.buttonText = "refresh"
        }
        Loader {
            sourceComponent: navButtonComponent
            onLoaded: item.buttonText = "explosion"
        }
    }
}
