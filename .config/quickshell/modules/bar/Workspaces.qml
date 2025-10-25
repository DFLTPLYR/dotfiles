import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland

import qs
import qs.assets
import qs.utils
import qs.services

Item {
    id: root

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
        anchors.fill: parent
        spacing: 2
        Repeater {
            model: Hyprland.workspaces
            delegate: Item {
                required property var modelData
                height: parent.height
                width: height
                visible: modelData.id >= 0

                Rectangle {
                    id: monitorIndicator
                    anchors.centerIn: parent
                    height: parent.height
                    width: height
                    radius: height * 0.2
                    color: mouseArea.containsMouse ? Scripts.setOpacity(ColorPalette.color14, 0.4) : (modelData.active && modelData.focused) ? ColorPalette.color2 : "transparent"

                    // Animate the fill color
                    Behavior on color {
                        ColorAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: romanNumber(modelData.id - 1)
                        color: mouseArea.containsMouse ? ColorPalette.color14 : (modelData.active && modelData.focused) ? ColorPalette.color14 : ColorPalette.color2
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
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            modelData.activate();
                            var apps = modelData.toplevels;
                            for (var i = 0; i < apps.values.length; i++) {
                                console.log(JSON.stringify(apps.values[i].class));
                            }
                        }
                    }
                }
            }
        }
    }
}
