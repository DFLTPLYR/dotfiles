import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import Quickshell
import Quickshell.Io

import qs
import qs.config
import qs.utils
import qs.config
import qs.assets
import qs.services

Item {
    id: root
    implicitWidth: parent.width
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter

    Material.theme: Material.Dark
    Material.accent: Color.color10

    Component {
        id: navButtonComponent
        Item {
            width: 32
            height: 32
            property string buttonText: ""
            property var onClickedAction: function () {}
            RoundButton {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                hoverEnabled: true

                text: buttonText
                font.pixelSize: 16
                font.family: FontProvider.fontMaterialOutlined
                contentItem: Text {
                    text: parent.text
                    color: Color.color14
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Behavior on color {
                        ColorAnim {}
                    }
                }

                background: Rectangle {
                    color: Color.color0
                    radius: width / 2

                    Behavior on color {
                        ColorAnim {}
                    }
                }

                onHoveredChanged: {
                    if (hovered) {
                        background.color = Color.color2;
                        contentItem.color = Color.color15;
                    } else {
                        background.color = Color.color0;
                        contentItem.color = Color.color14;
                    }
                }
                onClicked: onClickedAction()
            }
        }
    }

    Component {
        id: portraitLayout
        Column {
            anchors.fill: parent

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
                onLoaded: {
                    item.buttonText = "nightlight";
                    item.onClickedAction = function () {
                        handleText.text = "nightlight";
                        root.showNightLight = !root.showNightLight;

                        if (root.showNightLight) {
                            var screenTemp = MonitorExample.temperature;
                            control.from = screenTemp.min;
                            control.to = screenTemp.max;
                            root.ignoreValueChange = true;
                            control.value = root.lastNightLightValue;
                            Qt.callLater(() => {
                                root.ignoreValueChange = false;
                            });
                        }

                        if (root.showBrightness)
                            root.showBrightness = false;
                    };
                }
            }

            Loader {
                sourceComponent: navButtonComponent
                onLoaded: {
                    item.buttonText = "explosion";
                    item.onClickedAction = function () {
                        handleText.text = "explosion";
                        root.showBrightness = !root.showBrightness;

                        if (root.showBrightness) {
                            var screenGamma = MonitorExample.gamma;
                            control.from = screenGamma.min;
                            control.to = screenGamma.max;
                            root.ignoreValueChange = true;
                            control.value = root.lastBrightnessValue;
                            Qt.callLater(() => {
                                root.ignoreValueChange = false;
                            });
                        }

                        if (root.showNightLight)
                            root.showNightLight = false;
                    };
                }
            }
        }
    }

    Component {
        id: landscapeLayout

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
                onLoaded: {
                    item.buttonText = "nightlight";
                    item.onClickedAction = function () {
                        handleText.text = "nightlight";
                        root.showNightLight = !root.showNightLight;

                        if (root.showNightLight) {
                            var screenTemp = MonitorExample.temperature;
                            control.from = screenTemp.min;
                            control.to = screenTemp.max;
                            root.ignoreValueChange = true;
                            control.value = root.lastNightLightValue;
                            Qt.callLater(() => {
                                root.ignoreValueChange = false;
                            });
                        }

                        if (root.showBrightness)
                            root.showBrightness = false;
                    };
                }
            }

            Loader {
                sourceComponent: navButtonComponent
                onLoaded: {
                    item.buttonText = "explosion";
                    item.onClickedAction = function () {
                        handleText.text = "explosion";
                        root.showBrightness = !root.showBrightness;

                        if (root.showBrightness) {
                            var screenGamma = MonitorExample.gamma;
                            control.from = screenGamma.min;
                            control.to = screenGamma.max;
                            root.ignoreValueChange = true;
                            control.value = root.lastBrightnessValue;
                            Qt.callLater(() => {
                                root.ignoreValueChange = false;
                            });
                        }

                        if (root.showNightLight)
                            root.showNightLight = false;
                    };
                }
            }
        }
    }

    Loader {
        id: layoutLoader
        anchors.fill: parent
        sourceComponent: Config.navbar.side ? portraitLayout : landscapeLayout
    }
}
