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
    implicitWidth: monitorRow.implicitWidth
    implicitHeight: monitorRow.implicitHeight
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

                    color: hovered ? Scripts.setOpacity(Assets.color14, 0.4) : (modelData.active && modelData.focused) ? Assets.color2 : "transparent"
                    border.color: hovered ? Scripts.setOpacity(Assets.color14, 0.4) : (modelData.active && modelData.focused) ? Assets.color2 : Assets.color3

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
                        text: kanjiNumber(modelData.id - 1)
                        color: monitorIndicator.hovered ? Assets.color2 : (modelData.active && modelData.focused) ? Assets.color14 : Assets.color2
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
            }
        }
    }
}
