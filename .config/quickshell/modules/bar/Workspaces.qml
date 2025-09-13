import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import qs
import qs.assets
import qs.utils
import qs.services
import qs.modules

Item {
    id: root
    implicitWidth: parent.width
    implicitHeight: 32
    anchors.verticalCenter: parent.verticalCenter
    function kanjiNumber(n) {
        const kanji = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];
        return kanji[n] !== undefined ? kanji[n] : n.toString();
    }

    function romanNumber(n) {
        const roman = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"];
        return roman[n] !== undefined ? roman[n] : n.toString();
    }

    Row {
        id: monitorRow
        Repeater {
            model: Hyprland.workspaces
            delegate: Item {
                width: 32
                height: 32
                visible: modelData.id >= 0

                Rectangle {
                    id: monitorIndicator
                    anchors.centerIn: parent
                    width: parent.width * 0.7
                    height: parent.height * 0.7
                    radius: 100

                    // Track hover state
                    property bool hovered: false

                    color: hovered ? Scripts.setOpacity(ColorPalette.color14, 0.4) : (modelData.active && modelData.focused) ? ColorPalette.color2 : "transparent"
                    border.color: hovered ? Scripts.setOpacity(ColorPalette.color14, 0.4) : (modelData.active && modelData.focused) ? ColorPalette.color2 : ColorPalette.color3

                    // Animate the fill color
                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: romanNumber(modelData.id - 1)
                        // text: modelData.id
                        color: monitorIndicator.hovered ? ColorPalette.color2 : (modelData.active && modelData.focused) ? ColorPalette.color14 : ColorPalette.color2
                        font.pixelSize: {
                            var minSize = 10;
                            return Math.max(minSize, Math.min(height, width) * 0.6);
                        }
                        // Animate the fill color
                        Behavior on color {
                            ColorAnimation {
                                duration: 250
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: modelData.activate()
                        onEntered: {
                            monitorIndicator.hovered = true;
                        }
                        onExited: monitorIndicator.hovered = false
                    }
                }

                Component.onCompleted: {
                    Hyprland.refreshToplevels();
                    var applications = modelData.toplevels.values;
                    for (var i = 0; i < applications.length; i++) {
                        var app = applications[i];
                        if (app.lastIpcObject) {
                            // var keys = Object.keys(app.lastIpcObject);
                            // for (var j = 0; j < keys.length; j++) {
                            //     var key = keys[j];
                            //     console.log("App", i, key + ":", app.lastIpcObject[key]);
                            // }
                            console.log(app.lastIpcObject.class);
                        }
                    }
                }
            }
        }
    }
}
