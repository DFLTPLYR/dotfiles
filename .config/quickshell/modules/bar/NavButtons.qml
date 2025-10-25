import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import Quickshell
import Quickshell.Io

import qs
import qs.utils
import qs.assets
import qs.services

Item {
    id: root
    implicitWidth: parent.width
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter

    Material.theme: Material.Dark
    Material.accent: ColorPalette.color10

    property bool showBrightness: false
    property bool showNightLight: false
    property int sliderValue: 0

    property bool ignoreValueChange: false
    property int lastNightLightValue: 50
    property int lastBrightnessValue: 50
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

                    Behavior on color {
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

        Slider {
            id: control

            opacity: root.showBrightness || root.showNightLight ? 1 : 0
            enabled: root.showBrightness || root.showNightLight
            anchors.verticalCenter: parent.verticalCenter
            live: false

            onValueChanged: {
                console.log("onValueChanged called - value:", control.value, "ignoreValueChange:", root.ignoreValueChange, "showBrightness:", root.showBrightness, "showNightLight:", root.showNightLight);
                if (root.ignoreValueChange)
                    return;
                root.sliderValue = control.value;
                if (root.showNightLight) {
                    root.lastNightLightValue = control.value;
                } else if (root.showBrightness) {
                    root.lastBrightnessValue = control.value;
                }

                if ((root.showBrightness || root.showNightLight) && !root.ignoreValueChange) {
                    console.log("Executing detached command for", root.showBrightness ? "brightness" : "nightlight", "with value", root.sliderValue);
                    Quickshell.execDetached({
                        command: ["sh", "-c", `hyprctl hyprsunset ${root.showBrightness ? "gamma" : "temperature"} ${root.sliderValue}`]
                    });

                    MonitorExample.commandProc.command = ["sh", "-c", "hyprctl hyprsunset gamma && hyprctl hyprsunset temperature"];
                    MonitorExample.commandProc.running = true;
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }

            handle: Rectangle {
                x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                y: control.topPadding + control.availableHeight / 2 - height / 2
                implicitWidth: 8
                implicitHeight: 8
                color: "transparent"
                Text {
                    id: handleText
                    color: ColorPalette.color14
                    font.family: FontProvider.fontMaterialOutlined
                    anchors.centerIn: parent
                    font.pixelSize: Math.min(control.height, control.width) * 0.5
                    Behavior on color {
                        AnimationProvider.ColorAnim {}
                    }
                }
            }
        }
    }
}
